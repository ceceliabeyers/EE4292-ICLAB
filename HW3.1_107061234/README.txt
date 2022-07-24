HW3.1_107061234
--------------------------------------------
Module|Timing(ns)|Area(um^2)|Total Power(uW)
--------------------------------------------
lut256|   1.8    |   2090   |    589.226
smart |   1.8    |   1609   |    569.347
--------------------------------------------
Summarize:
	From the above data, we can observe that under the same clock period, the synthesis area and total power of lut256 are larger than that of the smart
way. Since the design compiler may simplify the logic of look-up table, it may still more complicate than the logic of the smart way. This reason cause
the performance(area and power) of smart way be better.
