# CIEDE2000 color difference formula in Swift

This page presents the CIEDE2000 color difference, implemented in the Swift programming language.

![Logo](https://raw.githubusercontent.com/michel-leonard/ciede2000-color-matching/refs/heads/main/docs/assets/images/logo.jpg)

## Our CIEDE2000 offer

These 2 production-ready files, released in 2026, contain the CIEDE2000 algorithm.

Source File|Type|Bits|Purpose|Advantage|
|:--:|:--:|:--:|:--:|:--:|
[ciede2000-32-bits.swift](./ciede2000-32-bits.swift)|`Float`|32|General|Lightness, Speed|
[ciede2000-64-bits.swift](./ciede2000-64-bits.swift)|`Double`|64|Scientific|Interoperability|

### Software Versions

- Swift 6.1.2 

### Example Usage

We calculate the CIEDE2000 distance between two colors, first without and then with parametric factors.

```swift
// Example of two L*a*b* colors
let l1 = 73.9, a1 = 58.9, b1 = -10.7
let l2 = 78.8, a2 = 99.1, b2 = 26.0

var delta_e = ciede2000(l1, a1, b1, l2, a2, b2)
print("CIEDE2000 = \(delta_e)") // ΔE2000 = 16.46519883470241

// Example of parametric factors used in the textile industry
let kl = 2.0, kc = 1.0, kh = 1.0

// Perform a CIEDE2000 calculation compliant with that of Gaurav Sharma
let canonical = true

delta_e = ciede2000(l1, a1, b1, l2, a2, b2, kl, kc, kh, canonical)
print("CIEDE2000 = \(delta_e)") // ΔE2000 = 16.17960429102669
```

These CIEDE2000 calculations in Swift are fast, typically allowing millions of color comparisons per second.

### Test Results

LEONARD’s tests are based on well-chosen L\*a\*b\* colors, with various parametric factors `kL`, `kC` and `kH`.

<details>
<summary>Display test results for 3 correct decimal places in 32-bits</summary>
     
```
CIEDE2000 Verification Summary :
          Compliance : [ ] CANONICAL [X] SIMPLIFIED
  First Checked Line : 40.0,0.5,-128.0,49.91,0.0,24.0,1.0,1.0,1.0,51.0186539
           Precision : 3 decimal digits
           Successes : 10000000
               Error : 0
            Duration : 47.01 seconds
     Average Delta E : 63.58
   Average Deviation : 8.8e-06
   Maximum Deviation : 0.00019
```

```
CIEDE2000 Verification Summary :
          Compliance : [X] CANONICAL [ ] SIMPLIFIED
  First Checked Line : 40.0,0.5,-128.0,49.91,0.0,24.0,1.0,1.0,1.0,51.0184669
           Precision : 3 decimal digits
           Successes : 10000000
               Error : 0
            Duration : 47.30 seconds
     Average Delta E : 63.58
   Average Deviation : 8.5e-06
   Maximum Deviation : 0.00019
```

</details>

<details>
<summary>Display test results for 12 correct decimal places in 64-bits</summary>
     
```
CIEDE2000 Verification Summary :
          Compliance : [ ] CANONICAL [X] SIMPLIFIED
  First Checked Line : 30.0,32.0,32.0,30.0,128.0,-127.4,1.0,1.0,1.0,45.32058741681242
           Precision : 12 decimal digits
           Successes : 100000000
               Error : 0
            Duration : 477.60 seconds
     Average Delta E : 67.13
   Average Deviation : 7.8e-15
   Maximum Deviation : 2.3e-13
```

```
CIEDE2000 Verification Summary :
          Compliance : [X] CANONICAL [ ] SIMPLIFIED
  First Checked Line : 30.0,32.0,32.0,30.0,128.0,-127.4,1.0,1.0,1.0,45.32039725637799
           Precision : 12 decimal digits
           Successes : 100000000
               Error : 0
            Duration : 489.57 seconds
     Average Delta E : 67.13
   Average Deviation : 7.2e-15
   Maximum Deviation : 2.3e-13
```

</details>

## Public Domain Licence

You are free to use these files, even for commercial purposes.
