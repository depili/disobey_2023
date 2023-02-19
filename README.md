# Disobey 2023 CTF challenges written by me

* Kouvosto-vps-300p;
  * Unfortunately there was a typo in the binary submitted, resulting in flag 1 being wrong
    * This was corrected at the end of the CTF when I became aware and points were awarded to anyone who submitted the typoed flag, sorry
  * A challenge based on a video mixer console I reverse engineered 5 years ago
  * More a "needle in a heystack" style challenge
  * finding https://github.com/depili/vps-300p/tree/master/rom/rom1_custom provides sources of most of the code
* kt_totp
  * An electronics reverse engineering challenge with logic analyzer trace.
  * Should have kept it simpler...
* mighty_morphing
  * Z80 binary with some self-modifying code
* register_your_flag
  * Z80 binary using the F (flag) register as part of the xor key for the flag