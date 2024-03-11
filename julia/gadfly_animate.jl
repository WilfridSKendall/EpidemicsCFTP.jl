using Gadfly
import Cairo, Fontconfig
using Printf
using FFMPEG

#################################### This is pretty much the same code as in https://github.com/JuliaPlots/Plots.jl/blob/master/src/animation.jl
struct Animation
    dir::String
    frames::Vector{String}
    kwargs::Iterators.Pairs
end

function Animation(; kwargs...)
    tmpdir = convert(String, mktempdir())
    Animation(tmpdir, String[], kwargs)
end

struct AnimatedGif
    filename::String
end

file_extension(fn) = Base.Filesystem.splitext(fn)[2][2:end]

default_fn() = tempname() * ".gif"
gif(anim::Animation, fn=default_fn()) = buildanimation(anim, fn; anim.kwargs...)
ffmpeg_framerate(fps) = "$fps"
ffmpeg_framerate(fps::Rational) = "$(fps.num)/$(fps.den)"

function frame!(anim::Animation, p; dpi=nothing, width=Compose.default_graphic_width, height=Compose.default_graphic_height, kwargs...)
    i = length(anim.frames) + 1
    filename = @sprintf("%06d.png", i)
    draw(PNG(joinpath(anim.dir, filename), width, height, dpi=dpi), p)
    push!(anim.frames, filename)
end

function buildanimation(
    anim::Animation,
    fn::String;
    fps::Real = 20,
    loop::Integer = 0,
    verbose = false,
    show_msg::Bool = true,
    kwargs...
)
    if length(anim.frames) == 0
        throw(ArgumentError("Cannot build empty animations"))
    end

    fn = abspath(expanduser(fn))
    animdir = anim.dir
    framerate = ffmpeg_framerate(fps)
    verbose_level = (verbose isa Int ? verbose : verbose ? 32 : 16) # "error"

    # generate a colorpalette first so ffmpeg does not have to guess it
    ffmpeg_exe(
        `-v $verbose_level -i $(animdir)/%06d.png -vf "palettegen=stats_mode=diff" -y "$(animdir)/palette.bmp"`,
    )
    # then apply the palette to get better results
    ffmpeg_exe(
        `-v $verbose_level -framerate $framerate -i $(animdir)/%06d.png -i "$(animdir)/palette.bmp" -lavfi "paletteuse=dither=sierra2_4a" -loop $loop -y $fn`,
    )

    show_msg && @info("Saved animation to ", fn)
    AnimatedGif(fn)
end

function Base.show(io::IO, ::MIME"text/html", agif::AnimatedGif)
    ext = file_extension(agif.filename)
    if ext == "gif"
        html =
            "<img src=\"data:image/gif;base64," *
            base64encode(read(agif.filename)) *
            "\" />"
    elseif ext in ("mov", "mp4", "webm")
        mimetype = ext == "mov" ? "video/quicktime" : "video/$ext"
        html =
            "<video controls><source src=\"data:$mimetype;base64," *
            base64encode(read(agif.filename)) *
            "\" type = \"$mimetype\"></video>"
    else
        error("Cannot show animation with extension $ext: $agif")
    end

    write(io, html)
    return nothing
end

Base.showable(::MIME"image/gif", agif::AnimatedGif) = file_extension(agif.filename) == "gif"

function Base.show(io::IO, ::MIME"image/gif", agif::AnimatedGif)
    open(fio -> write(io, fio), agif.filename)
end

function _animate(forloop::Expr, callgif=false; kwargs...)
    if forloop.head ∉ (:for, :while)
        error("@animate macro expects a for- or while-block. got: $(forloop.head)")
    end

    animsym = gensym("anim")
    p = gensym("p")
    
    block = forloop.args[2]
    forloop.args[2] = quote
        $p = $block
        frame!($animsym, $p; $kwargs...)
    end
    retval = callgif ? :(gif($animsym)) : anymsim
    
    esc(quote
        $animsym = Animation(; $kwargs...)
        $forloop
        $retval
    end)
end

macro animate(forloop::Expr, args...)
    _animate(forloop; eval(args...)...)
end

macro gif(forloop::Expr, args...)
    _animate(forloop, true; eval(args...)...)
end

# #################################### Example usage. 
# # The for loop inner-block should return a plot for the current frame
# @gif for i=0:0.01:1
#     p = plot(
#         x=[cos(2pi*i)*(1-i)], y=[sin(2pi*i)*(1-i)], Geom.point, 
#         Coord.cartesian(xmin=-1, xmax=1, ymin=-1, ymax=1), 
#     )
#     p = vstack(p, p)
#     hstack(p, p)
# end (fps=50, dpi=100)

# Note that kwargs are passed through the macro. This is done to be able to pass arguments to the PNG function when creating frames. Otherwise you are not able to change the resolution of the PNGs and the GIF ends up looking 96dpi bad...
