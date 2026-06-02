# Phonetic features of consonants and vowels

This package provides dataframes of information about the consonants and
vowels in American English. The *phonetic* features are conventional
descriptions of how sounds are produced. See also
[data_acq_consonants](https://wisclab.github.io/wisclabmisc/reference/data_acq_consonants.md).

## Usage

``` r
data_features_consonants

data_features_vowels
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 24
rows and 11 columns.

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 17
rows and 13 columns.

## Details

Most of the phonetic features are self-evident and definitional. For
example, /p/ is *the* bilabial voiceless stop. For fuzzier features, I
consulted the general IPA chart and the Wikipedia page on English
phonology. These issues included things like: *what are the lax vowels
again?* or *the last two rows of the consonant tables are approximants,
so /r,l,j/ are approximants.*

Some features have alternative feature sets in order to accommodate
degrees of aggregation. For example, /r,l,j,w/ are *approximant* in
`manner` but divided into *liquid* and *glide* in `manner_alt`.

### Phonetic features of consonants

`data_features_consonants` is a dataframe with 24 rows and 10 variables.

    knitr::kable(data_features_consonants)

|  |  |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|----|
| phone | cmubet | wiscbet | voicing | voicing_alt | manner | manner_alt | place | place_fct | sonorance | sonorance_alt |
| p | P | p | voiceless | spread_glottis | stop | stop | labial | labial | obstruent | obstruent |
| b | B | b | voiced | plain | stop | stop | labial | labial | obstruent | obstruent |
| t | T | t | voiceless | spread_glottis | stop | stop | alveolar | alveolar | obstruent | obstruent |
| d | D | d | voiced | plain | stop | stop | alveolar | alveolar | obstruent | obstruent |
| k | K | k | voiceless | spread_glottis | stop | stop | velar | velar | obstruent | obstruent |
| g | G | g | voiced | plain | stop | stop | velar | velar | obstruent | obstruent |
| tʃ | CH | tsh | voiceless | spread_glottis | affricate | affricate | postalveolar | postalveolar | obstruent | strident |
| dʒ | JH | dzh | voiced | plain | affricate | affricate | postalveolar | postalveolar | obstruent | strident |
| m | M | m | voiced | NA | nasal | nasal | labial | labial | sonorant | sonorant |
| n | N | n | voiced | NA | nasal | nasal | alveolar | alveolar | sonorant | sonorant |
| ŋ | NG | ng | voiced | NA | nasal | nasal | velar | velar | sonorant | sonorant |
| f | F | f | voiceless | spread_glottis | fricative | fricative | labiodental | labiodental | obstruent | strident |
| v | V | v | voiced | plain | fricative | fricative | labiodental | labiodental | obstruent | strident |
| θ | TH | th | voiceless | spread_glottis | fricative | fricative | dental | dental | obstruent | obstruent |
| ð | DH | dh | voiced | plain | fricative | fricative | dental | dental | obstruent | obstruent |
| s | S | s | voiceless | spread_glottis | fricative | fricative | alveolar | alveolar | obstruent | strident |
| z | Z | z | voiced | plain | fricative | fricative | alveolar | alveolar | obstruent | strident |
| ʃ | SH | sh | voiceless | spread_glottis | fricative | fricative | postalveolar | postalveolar | obstruent | strident |
| ʒ | ZH | zh | voiced | plain | fricative | fricative | postalveolar | postalveolar | obstruent | strident |
| h | HH | h | voiceless | spread_glottis | fricative | fricative | glottal | glottal | obstruent | obstruent |
| l | L | l | voiced | NA | approximant | liquid | alveolar | alveolar | sonorant | sonorant |
| r | R | r | voiced | NA | approximant | liquid | postalveolar | postalveolar | sonorant | sonorant |
| w | W | w | voiced | NA | approximant | glide | labiovelar | NA | sonorant | sonorant |
| j | Y | j | voiced | NA | approximant | glide | palatal | palatal | sonorant | sonorant |

Description of each column:

- phone:

  phone in IPA

- cmubet:

  phone in the CMU alphabet

- wiscbet:

  phone in an older system used by our lab

- voicing:

  *voiced* versus *voiceless*

- voicing_alt:

  *spread_glottis* versus *plain*

- manner:

  manner of articulation

- manner_alt:

  alternative manner coding that separates *approximants* into *liquids*
  and *glides*

- place:

  place of articulation

- place_fct:

  place coded as a factor and ordered based on frontness of the
  articulators. *labiovelar* is recoded as `NA`.

- sonorance:

  *obstruent* versus *sonorant*

- sonorance_alt:

  *obstruant* versus *sonorant* versus *strident*.

Levels of the factor columns:

    data_features_consonants |>
      lapply(levels) |>
      Filter(length, x = _)
    #> $place_fct
    #> [1] "labial"       "labiodental"  "dental"       "alveolar"     "postalveolar"
    #> [6] "palatal"      "velar"        "glottal"

### Considerations about consonant phonetic features

The CMU alphabet does not include a glottal stop.

Here /f,v/ are coded as *strident* following
[Wikipedia](https://en.wikipedia.org/wiki/Sibilant) and *Sound Pattern
of English*. If this feature value doesn't seem right, we should
probably use an alternative feature of *sibilant* for the stridents
minus /f,v/.

The alternative voicing scheme was suggested by a colleague because of
how the voice-voiceless phonetic contrast is achieved with different
articulatory strategies in different languages. Note that `voicing_alt`
does not assign a feature to nasals or approximants.

### Phonetic features of vowels

`data_features_vowels` is a dataframe with 17 rows and 11 variables.

    knitr::kable(data_features_vowels)

|  |  |  |  |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|----|----|----|
| phone | cmubet | wiscbet | hint | manner | manner_alt | tenseness | height | height_fct | height_alt | backness | backness_fct | rounding |
| i | IY | i | beat | vowel | vowel | tense | high | high | high | front | front | unrounded |
| ɪ | IH | I | bit | vowel | vowel | lax | mid-high | mid-high | high | front | front | unrounded |
| eɪ | EY | eI | bait | vowel | vowel | tense | mid-high | mid-high | mid | front | front | unrounded |
| ɛ | EH | E | bet | vowel | vowel | lax | mid-low | mid-low | mid | front | front | unrounded |
| æ | AE | ae | bat | vowel | vowel | lax | low | low | low | front | front | unrounded |
| ʌ | AH | ^ | but | vowel | vowel | lax | mid-low | mid-low | mid | central | central | unrounded |
| ə | AH | 4 | comma | vowel | vowel | lax | mid-low | mid-low | mid | central | central | unrounded |
| u | UW | u | boot | vowel | vowel | tense | high | high | high | back | back | rounded |
| ʊ | UH | U | book | vowel | vowel | lax | mid-high | mid-high | high | back | back | rounded |
| oʊ | OW | oU | boat | vowel | vowel | tense | mid-high | mid-high | mid | back | back | rounded |
| ɔ | AO | c | bought | vowel | vowel | tense | mid-low | mid-low | low | back | back | rounded |
| ɑ | AA | @ | bot | vowel | vowel | tense | low | low | low | back | back | unrounded |
| aʊ | AW | @U | bout | vowel | diphthong | diphthong | diphthong | NA | diphthong | diphthong | NA | diphthong |
| aɪ | AY | @I | bite | vowel | diphthong | diphthong | diphthong | NA | diphthong | diphthong | NA | diphthong |
| ɔɪ | OY | cI | boy | vowel | diphthong | diphthong | diphthong | NA | diphthong | diphthong | NA | diphthong |
| ɝ | ER | 3^ | letter | vowel | r-colored | r-colored | mid-low | mid-low | mid | central | central | r-colored |
| ɚ | ER | 4^ | burt | vowel | r-colored | r-colored | mid-low | mid-low | mid | central | central | r-colored |

Description of each column:

- phone:

  phone in IPA

- cmubet:

  phone in the CMU alphabet

- wiscbet:

  phone in an older system used by our lab

- hint:

  a word containing the selected vowel

- manner:

  manner of articulation

- manner_alt:

  alternative manner with *vowel*, *diphthong* and *r-colored*

- tenseness:

  *tense* versus *lax* (versus *diphthong* and *r-colored*)

- height:

  vowel height on a four-level scale

- height_fct:

  height coded as a factor ordered *high*, *mid-high*, *mid-low*, *low*.
  *diphthong* is recoded to `NA`.

- height_alt:

  vowel height on a three-level scale

- backness:

  vowel backness

- backness_fct:

  backness coded as a factor ordered *front*, *central*, *back*.
  *diphthong* is recoded to `NA`.

- rounding:

  *unrounded* versus *rounded* (versus *diphthong* and *r-colored*)

Levels of the factor columns:

    data_features_vowels |>
      lapply(levels) |>
      Filter(length, x = _)
    #> $height_fct
    #> [1] "high"     "mid-high" "mid-low"  "low"
    #>
    #> $backness_fct
    #> [1] "front"   "central" "back"

### Considerations about vowel features

I don't consider /eɪ/ and /oʊ/ to be diphthongs, but perhaps
`manner_alt` could encode the difference of these vowels from the
others.

In the CMU alphabet and ARPAbet, vowels can include a number to indicate
vowel stress, so `AH1` or `AH2` is /ʌ/ but `AH0` is /ə/.

The vowel features for General American English, [according to
Wikipedia](https://en.wikipedia.org/wiki/English_phonology), are as
follows:

|            |          |       |         |       |      |       |
|------------|----------|-------|---------|-------|------|-------|
|            | Front    |       | Central |       | Back |       |
|            | lax      | tense | lax     | tense | lax  | tense |
| Close      | ɪ        | i     |         |       | ʊ    | u     |
| Mid        | ɛ        | eɪ    | ə       | (ɜ)   |      | oʊ    |
| Open       | æ        |       | (ʌ)     | ɑ     |      | (ɔ)   |
| Diphthongs | aɪ ɔɪ aʊ |       |         |       |      |       |

I adapted these features in this way:

- A four-level breakdown of height (high, mid-high, mid-low, low) was
  used instead of a three-level one (close, mid, open).

- *tense* and *lax* features were directly borrowed. Diphthongs and
  r-colored vowels are were not assign a tenseness.

- /ɑ/ moved to *back* (following the general IPA)

- diphthongs have no backness or height

- r-colored vowels were given the backness and height of the /ʌ,ə/

Based on the assumption that /ʌ,ə/ are the same general vowel with
differing stress, these vowels have the same features. This definition
clashes with the general IPA chart which places /ʌ/ as a back vowel.
However, /ʌ/ is a conventional notation. Quoting
[Wikipedia](https://en.wikipedia.org/wiki/English_phonology) again:
"Although the notation /ʌ/ is used for the vowel of STRUT in RP and
General American, the actual pronunciation is closer to a near-open
central vowel \[ɐ\] in RP and advanced back \[ʌ̟\] in General American."
That is, /ʌ/ is fronted in American English (hence, *mid*) in American
English.
