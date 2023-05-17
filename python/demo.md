Demonstration
=============
This example should give scope for no-fly zones, Mordor, and last viable infections.


  python3 static.py --title="Drawing a diagram from last week" \
      --remove="[[], [], [0.65], [0.75], [0.98], [0.1, 0.4, 0.9, 1.05, 1.5]]" \
      --infect="[[[0.1, 0.15, 0.25]], \
                [[], [0.05, 0.2]],    \
                [[], [0.6], [0.009, 0.12, 0.24, 0.5]], \
                [[1.1, 1.2], [], [0.95], [0.21]], \
                [[], [], [], [1.4],  [0.35, 1.25, 1.35]]]"

                
Stephen remarks, "One feature that this example doesn't have (I think) is any potential infections lying strictly between the no-fly zone and epidemic trajectory, which might it might be helpful to include. I've tweaked a couple of infections to attempt to do this". Here is Stephen's amended version:

  python3 static.py --title="Drawing a diagram from last week" \
    --remove="[[], [], [0.65], [0.75], [0.98], [0.1, 0.4, 0.9, 1.05, 1.5]]" \
    --infect="[[[0.1, 0.15, 0.25]], \
              [[], [0.05, 0.2]],    \
              [[], [0.6], [0.009, 0.12, 0.5]], \
              [[1.1, 1.2], [], [0.95], [0.21, 0.45]], \
              [[], [], [], [1.4],  [0.35, 1.25, 1.35]]]"
