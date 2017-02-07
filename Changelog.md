## 1.0.8

* Increase upper bound of `time`.

## 1.0.7

* Now builds with GHC 8.0.1

## 1.0.6

* Use `bracketOnError` when opening the network socket. Thanks to @purefn
  for this improvement, which should stop `network-carbon` leaking file
  descriptors when connections fail.

## 1.0.5

* Correct the lower-bound of `bytestring` (introduced by @bergmark in 1.0.3)

## 1.0.4

* Increased upper-bound of `vector`.

## 1.0.3

* Increased upper-bounds of:

      * `base`
      * `time`


## 1.0.2

* Increased upper-bounds of:

      * `network`
      * `text`

  Thanks to Peter Simons (@peti) for pointing this out.


## 1.0.1

* Decreased lower-bounds of:

      * `bytestring`
      * `network`
      * `text`
      * `time`
      * `vector`

  Thanks to Renzo Carbonara (@k0001) for this change.


## 1.0.0

* Initial release.
