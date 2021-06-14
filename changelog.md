The changes on the project will be written here.

# 1.0 - 2021-06-09
- Initial release

# 1.1 - 2021-06-10

### Changed

- Now baudgen resets every tx_val signal rising edge.
- readme.md is updated.

# 1.2 - 2021-06-14

### Changed

- baudgen tx and rx pulses now resets every busy and rx_val signal rising edges.
- Now busy and rx_val signals are used to increment the pulse counters. 
- Pulses will be 0 if there are no busy or rx_val signals.
- readme.md updated.