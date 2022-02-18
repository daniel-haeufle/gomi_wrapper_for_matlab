# Tutorial: how to calculate morphological computation with gomi

## Resources

- Description of gomi: http://keyan.ghazi-zahedi.eu/gomi
- Source code repository: https://github.com/kzahedi/gomi
- gomi wrapper for matlab: https://github.com/daniel-haeufle/gomi_wrapper_for_matlab.git
- Relevant publications: 
  - Zahedi, K., & Ay Nihat. (2013). Quantifying morphological computation. Entropy, 15, 1887–1915. https://doi.org/10.3390/e15051887
  - Ghazi-Zahedi, K., Haeufle, D. F. B., Montúfar, G., Schmitt, S., & Ay Nihat. (2016). Evaluating Morphological Computation in Muscle and DC-Motor Driven Models of Hopping Movements. Frontiers in Robotics and AI, 3, 1–12. https://doi.org/10.3389/frobt.2016.00042

## Wrapper explained

To calculate morphological computation with gomi, you need to generate two arrays in matlab. Both need to have the same number of rows (time steps). The first array contains in the columns all world and system state variables. The second array contains all actuator states (control signals and potentially higher-level controller states). 

To calculate MC, you can then simply call

[MC_discrete_mean, MC_discrete, MC_cont_mean, MC_cont] = gomi_wrapper(world, actuation)

which will compute morphological computation.

MC_discrete_mean is the value of morphological computation calculated with discrete binning for the entire movement.

MC_discrete is the time-based sampling. It has the same length as the input data and can be plotted as a function of time. In my opinion it is hard to interpret.

MC_cont_mean is the value of morphological computation calculated with a continuous estimation of the probabilities (see gomi documentation for details).

MC_cont is again the time-resolved data. Hard to interpret.

### what happens in the wrapper:

Internally, the wrapper generates one large array containing all signals. 

It then writes it to a .csv file and calls gomi via the terminal command line.

Additional parameters can be given in the wraper code (for details, see gomi documentation)

## example code

There is a folder with an example code. This code was used in the paper:

Haeufle, D. F. B., Stollenmaier, K., Heinrich, I., Schmitt, S., & Ghazi-Zahedi Keyan. (2020). Morphological computation increases from lower- to higher-level of biological motor control hierarchy. Frontiers in Robotics and AI, accepted, 1–13. https://doi.org/10.3389/frobt.2020.511265

The example only shows how to prepare the array and plot the results.