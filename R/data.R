

#' Intelligibility development from 30 to 119 months
#'
#' A dataset of speech intelligibility scores from 538 children.
#'
#' Citation:
#'
#' Hustad, K. C., Mahr, T. J., Natzke, P., & Rathouz, P. J. (2021). Speech
#' Development Between 30 and 119 Months in Typical Children I:
#' Intelligibility Growth Curves for Single-Word and Multiword Productions.
#' *Journal of Speech, Language, and Hearing Research*, 1–13.
#' <https://doi.org/10.1044/2021_jslhr-21-00142>
#'
#'
#' @noRd
#' @format A data frame with 1076 rows and 4 variables:
#' \describe{
#'   \item{child}{unique child id. each child has two rows in the dataset}
#'   \item{age_months}{child's age in months}
#'   \item{mean_intelligibility}{child's intelligibility, the proportion of
#'   words correctly transcribed by two naive listeners}
#'   \item{intelligibility_type}{type of speech stimuli, either `single-word` or
#'   `multiword`}
#' }
#' @source Associated article: <https://doi.org/10.1044/2021_jslhr-21-00142>
#' @concept datasets
NULL
# "intelligibility_growth"


#' Fake speaking rate data
#'
#' A dataset of fake speaking rate measures for testing and demonstrating
#' modeling functions. These were created by randomly
#' sampling 200 rows of a speaking rate dataset and adding random noise to the
#' `age_months` and `speaking_sps` variables. These values do not measure any
#' real children but represent plausible age and rate measurements from our
#' kind of work.
#'
#' @format A data frame with 200 rows and 2 variables:
#' \describe{
#'   \item{age_months}{child's age in months}
#'   \item{speaking_sps}{child's speaking rate in syllables per second}
#' }
#' @concept datasets
"data_fake_rates"


#' Fake intelligibility data
#'
#' A dataset of fake intelligibility scores for testing and demonstrating
#' modeling functions. These were created by randomly sampling 200 rows of an
#' intelligibility dataset and adding random noise to the `age_months` and
#' `intelligibility` variables. These values do not measure any real children
#' but represent plausible age and intelligibility measurements from our kind of
#' work.
#'
#' @format A data frame with 200 rows and 2 variables:
#' \describe{
#'   \item{age_months}{child's age in months}
#'   \item{intelligibility}{child's intelligibility (proportion of words said
#'   by the child that were correctly transcribed by two listeners)}
#' }
#' @concept datasets
"data_fake_intelligibility"


#' Simulated intelligibility scores by utterance length
#'
#' A dataset of simulated intelligibility scores for testing and demonstrating
#' modeling functions. These were created by fitting a Bayesian model of the raw
#' Hustad and colleagues (2020) and drawing 1 sample from the posterior
#' distribution of expected predictions (i.e., "epreds). In other words, these
#' values are model predictions of the original dataset. They are correlated
#' with original dataset values at *r* = .86. We might think of the simulation
#' as adding random noise to the original dataset.
#'
#' @format A data frame with 694 rows and 5 variables:
#' \describe{
#'   \item{child}{identifier for the child}
#'   \item{age_months}{child's age in months}
#'   \item{length_longest}{length of the child's longest utterance}
#'   \item{tocs_level}{utterance length}
#'   \item{sim_intelligibility}{child's intelligibility for the given utterance
#'   length (proportion of words said by the child that were correctly
#'   transcribed by two listeners)}
#' }
#' @references Hustad, K. C., Mahr, T., Natzke, P. E. M., & Rathouz, P. J.
#'   (2020). Development of Speech Intelligibility Between 30 and 47 Months in
#'   Typically Developing Children: A Cross-Sectional Study of Growth. *Journal
#'   of Speech, Language, and Hearing Research*, *63*(6), 1675–1687.
#'   https://doi.org/10.1044/2020_JSLHR-20-00008
#' @concept datasets
"data_example_intelligibility_by_length"




#' Phonetic features of consonants and vowels
#'
#' This package provides dataframes of information about the consonants and
#' vowels in American English. The *phonetic* features are conventional
#' descriptions of how sounds are produced. See also
#' [data_acq_consonants].
#'
#'
#' @details
#'
#' Most of the phonetic features are self-evident and definitional. For example, /p/ is
#' *the* bilabial voiceless stop. For fuzzier features, I consulted the general
#' IPA chart and the Wikipedia page on English phonology. These issues included
#' things like: *what are the lax vowels again?* or *the last two rows of the
#' consonant tables are approximants, so /r,l,j/ are approximants.*
#'
#' Some features have alternative feature sets in order to accommodate degrees
#' of aggregation. For example, /r,l,j,w/ are *approximant* in `manner`
#' but divided into *liquid* and *glide* in `manner_alt`.
#'
#' ## Phonetic features of consonants
#'
#'  `data_features_consonants` is a dataframe with 24 rows and
#' 10 variables.
#'
#' ```{r}
#' knitr::kable(data_features_consonants)
#' ```
#'
#' Description of each column:
#'
#' \describe{
#'   \item{phone}{phone in IPA}
#'   \item{cmubet}{phone in the CMU alphabet}
#'   \item{wiscbet}{phone in an older system used by our lab}
#'   \item{voicing}{*voiced* versus *voiceless*}
#'   \item{voicing_alt}{*spread_glottis* versus *plain*}
#'   \item{manner}{manner of articulation}
#'   \item{manner_alt}{alternative manner coding that separates *approximants*
#'   into *liquids* and *glides*}
#'   \item{place}{place of articulation}
#'   \item{place_fct}{place coded as a factor and ordered based on
#'   frontness of the articulators. *labiovelar* is recoded as `NA`.}
#'   \item{sonorance}{*obstruent* versus *sonorant*}
#'   \item{sonorance_alt}{*obstruant* versus *sonorant* versus *strident*.}
#' }
#'
#' Levels of the factor columns:
#'
#' ```{r}
#' data_features_consonants |>
#'   lapply(levels) |>
#'   Filter(length, x = _)
#' ```
#'
#' ## Considerations about consonant phonetic features
#'
#' The CMU alphabet does not include a glottal stop.
#'
#' Here /f,v/ are coded as *strident* following
#' [Wikipedia](https://en.wikipedia.org/wiki/Sibilant) and
#' *Sound Pattern of English*. If this feature value doesn't seem right, we
#' should probably use an alternative feature of *sibilant* for the
#' stridents minus /f,v/.
#'
#' The alternative voicing scheme was suggested by a colleague because of how
#' the voice-voiceless phonetic contrast is achieved with different articulatory
#' strategies in different languages. Note that `voicing_alt` does not assign
#' a feature to nasals or approximants.
#'
#' ## Phonetic features of vowels
#'
#' `data_features_vowels` is a dataframe with 17 rows and
#' 11 variables.
#'
#' ```{r}
#' knitr::kable(data_features_vowels)
#' ```
#'
#' Description of each column:
#'
#' \describe{
#'   \item{phone}{phone in IPA}
#'   \item{cmubet}{phone in the CMU alphabet}
#'   \item{wiscbet}{phone in an older system used by our lab}
#'   \item{hint}{a word containing the selected vowel}
#'   \item{manner}{manner of articulation}
#'   \item{manner_alt}{alternative manner with *vowel*, *diphthong* and *r-colored*}
#'   \item{tenseness}{*tense* versus *lax* (versus *diphthong* and *r-colored*)}
#'   \item{height}{vowel height on a four-level scale}
#'   \item{height_fct}{height coded as a factor ordered *high*,
#'   *mid-high*, *mid-low*, *low*. *diphthong* is recoded to `NA`.}
#'   \item{height_alt}{vowel height on a three-level scale}
#'   \item{backness}{vowel backness}
#'   \item{backness_fct}{backness coded as a factor ordered *front*,
#'   *central*, *back*. *diphthong* is recoded to `NA`.}
#'   \item{rounding}{*unrounded* versus *rounded* (versus *diphthong* and
#'   *r-colored*)}
#' }
#'
#' Levels of the factor columns:
#'
#' ```{r}
#' data_features_vowels |>
#'   lapply(levels) |>
#'   Filter(length, x = _)
#' ```
#'
#' ## Considerations about vowel features
#'
#' I don't consider /eɪ/ and /oʊ/ to be diphthongs, but perhaps `manner_alt`
#' could encode the difference of these vowels from the others.
#'
#' In the CMU alphabet and ARPAbet, vowels can include a number to indicate
#' vowel stress, so `AH1` or `AH2` is /ʌ/ but `AH0` is /ə/.
#'
#' The vowel features for General American English,
#' [according to Wikipedia](https://en.wikipedia.org/wiki/English_phonology),
#' are as follows:
#'
#' <table style="text-align: center;">
#'<tbody>
#' <tr class="header">
#' <th rowspan="2"></th>
#' <th colspan="2">Front</th>
#' <th colspan="2">Central</th>
#' <th colspan="2">Back</th>
#' </tr>
#' <tr class="odd">
#' <th>lax</th>
#' <th>tense</th>
#' <th>lax</th>
#' <th>tense</th>
#' <th>lax</th>
#' <th>tense</th>
#' </tr>
#'
#' <tr class="odd">
#'<th>Close</th>
#'<td>ɪ</td>
#'<td>i</td>
#'<td></td>
#'<td></td>
#'<td>ʊ</td>
#'<td>u</td>
#'</tr>
#'<tr class="even">
#'<th>Mid</th>
#'<td>ɛ</td>
#'<td>eɪ</td>
#'<td>ə</td>
#'<td>(ɜ)</td>
#'<td></td>
#'<td>oʊ</td>
#'</tr>
#'<tr class="odd">
#'<th>Open</th>
#'<td>æ</td>
#'<td></td>
#'<td>(ʌ)</td>
#'<td>ɑ</td>
#'<td></td>
#'<td>(ɔ)</td>
#'</tr>
#'<tr class="even">
#'<th>Diphthongs</th>
#'<td colspan="6">aɪ ɔɪ aʊ</td>
#'</tr>
#'</tbody>
#'</table>
#'
#' I adapted these features in this way:
#'
#' - A four-level breakdown of height (high, mid-high, mid-low, low) was used
#'   instead of a three-level one (close, mid, open).
#' - *tense* and *lax* features were directly borrowed. Diphthongs and
#'   r-colored vowels are were not assign a tenseness.
#' - /ɑ/ moved to *back* (following the general IPA)
#' - diphthongs have no backness or height
#' - r-colored vowels were given the backness and height of the /ʌ,ə/
#'
#' Based on the assumption that /ʌ,ə/ are the same general vowel with
#' differing stress, these vowels have the same features. This definition
#' clashes with the general IPA chart which places /ʌ/ as a back vowel. However,
#' /ʌ/ is a conventional notation. Quoting
#' [Wikipedia](https://en.wikipedia.org/wiki/English_phonology) again:
#' "Although the notation /ʌ/ is used for the vowel of STRUT in RP and General
#' American, the actual pronunciation is closer to a near-open central
#' vowel \[ɐ\] in RP and advanced back \[ʌ̟\] in General American." That is,
#' /ʌ/ is fronted in American English (hence, *mid*) in American English.
#'
#' @concept datasets
"data_features_consonants"

#' @rdname data_features_consonants
"data_features_vowels"




#' Acquisition and developmental descriptions of consonants and vowels
#'
#' This package provides dataframes of information about the consonants and
#' vowels in American English. The following datasets collect *acquisition*
#' (`acq`) features which (try to) characterize the expected acquisition or
#' speech-motor difficulty of speech sounds. See also
#' [data_features_consonants].
#'
#' @references Allison, K. M., & Hustad, K. C. (2014). Impact of sentence length and
#' phonetic complexity on intelligibility of 5-year-old children with
#' cerebral palsy. *International Journal of Speech-Language
#' Pathology*, *16*(4), 396–407.
#' <https://doi.org/10.3109/17549507.2013.876667>
#'
#' Crowe, K., & McLeod, S. (2020). Children’s English Consonant
#' Acquisition in the United States: A Review. *American Journal of
#' Speech-Language Pathology*,
#' *29*(4), 2155–2169. <https://doi.org/10.1044/2020_AJSLP-19-00168>
#'
#' Kent, R. D. (1992). The Biology of Phonological Development. In C. A.
#' Ferguson, L. Menn, & C. Stoel-Gammon (Eds.), *Phonological development:
#' Models, research, implications* (pp. 65–90). York Press.
#'
#' Kim, H., Martin, K., Hasegawa-Johnson, M., & Perlman, A. (2010).
#' Frequency of consonant articulation errors in dysarthric speech.
#' *Clinical Linguistics and Phonetics*, *24*(10), 759–770.
#' <https://doi.org/10.3109/02699206.2010.497238>
#'
#' Kuruvilla-Dugdale, M., Custer, C., Heidrick, L., Barohn, R., &
#' Govindarajan, R. (2018). A Phonetic Complexity-Based Approach for
#' Intelligibility and Articulatory Precision Testing: A Preliminary Study
#' on Talkers With Amyotrophic Lateral Sclerosis. *Journal of Speech,
#' Language, and Hearing Research*, *61*(9), 2205–2214.
#' <https://doi.org/10.1044/2018_JSLHR-S-17-0462>
#'
#' Mahr, T. J., & Hustad, K. C. (2023). Lexical Predictors of
#' Intelligibility in Young Children’s Speech. *Journal of Speech, Language,
#' and Hearing Research*, 66(8S), 3013–3025.
#' <https://doi.org/10.1044/2022_JSLHR-22-00294>
#'
#' Sander, E. K. (1972). When are Speech Sounds Learned? *Journal of Speech
#' and Hearing Disorders*, *37*(1), 55–63.
#' <https://doi.org/10.1044/jshd.3701.55>
#'
#' Shriberg, L. D. (1993). Four New Speech and Prosody-Voice Measures for
#' Genetics Research and Other Studies in Developmental Phonological Disorders.
#' *Journal of Speech, Language, and Hearing Research*, *36*(1), 105–140.
#' <https://doi.org/10.1044/jshr.3601.105>
#'
#' @rdname data_acq_consonants
#' @concept datasets
#'
#' @details ## Consonant acquisition features
#'
#' `data_acq_consonants` provides the following features:
#'
#' ```{r}
#' knitr::kable(data_acq_consonants)
#' ```
#'
#' Description of each column:
#'
#' \describe{
#'   \item{phone}{phone in IPA}
#'   \item{cmubet}{phone in the CMU alphabet}
#'   \item{wiscbet}{phone in an older system used by our lab}
#'   \item{cm2020_90_age_mean, cm2020_90_age_sd, cm2020_90_age_min,
#'   cm2020_90_age_max}{Age of acquisition statistics reported by Crowe &
#'   McLeod (2020). Statistics are the mean, SD, min and max age (in months)
#'   when children reached 90% accuracy on a consonant.}
#'   \item{cm2020_90_num_studies}{Number of studies used by Crowe & McLeod
#'   (2020) to compute the corresponding statistics.}
#'   \item{cm2020_90_stage}{Developmental stage assigned to the consonant by
#'   Crowe & McLeod (2020). Sounds with an `age_mean` before 48 months are
#'   `early`, before 60 months are `middle`, and of 60 or older are `late`.}
#'   \item{s93_eights}{Developmental stage of Shriberg (1993)---that is,
#'   the `early` 8, `middle` 8 and `late` 8 consonants.}
#'   \item{k1992_set}{Developmental set from Kent (1992). Sets corresponds
#'   to the age of 90% mastery in Sander (1972): Set 1 is mastered at age
#'   3-years-old, Set 2 at age 4, Set 3 at age 6, and Set 4 at a later age.}
#'   \item{kd2018_complexity}{Phonetic complexity scores from
#'   Kuruvilla-Dugdale et al. (2018). This scoring system is based on the
#'   development description of vowels and consonants in Kent (1992). The
#'   scores for individual segments range from 1 for the earliest vowels to
#'   6 for the last-acquired consonants. Under this system, assign a score to
#'   each part of a syllable (onset, nucleus, coda) using these scores when
#'   the syllable part is a single segment and using scores of 7 and 8 for
#'   2-consonant and 3-consonant clusters, respectively.}
#'   \item{hml84_frequency, hml84_log10fpm}{Raw frequency and log10 frequency
#'   per million of the phoneme in the Hoosier Mental Lexicon (Nusbaum, Pisoni,
#'   Pisoni, 1984) word-frequency dictionary.}
#'   \item{mhr82_frequency, mhr82_log10fpm}{Raw frequency and log10 frequency
#'   per million of the phoneme in the Moe, Hopkins, and Rush (1982) word
#'   frequency dictionary of first-graders.}
#' }
#'
#' ## Vowel acquisition features
#'
#' `data_acq_vowels` provides the following features:
#'
#' ```{r}
#' knitr::kable(data_acq_vowels)
#' ```
#'
#' \describe{
#'   \item{phone}{phone in IPA}
#'   \item{cmubet}{phone in the CMU alphabet}
#'   \item{wiscbet}{phone in an older system used by our lab}
#'   \item{kd2018_complexity}{Phonetic complexity scores from
#'   Kuruvilla-Dugdale et al. (2018). This scoring system is based on the
#'   development description of vowels and consonants in Kent (1992). The
#'   scores for individual segments range from 1 for the earliest vowels to
#'   6 for the last-acquired consonants. Under this system, assign a score to
#'   each part of a syllable (onset, nucleus, coda) using these scores when
#'   the syllable part is a single segment and using scores of 7 and 8 for
#'   2-consonant and 3-consonant clusters, respectively.}
#'   \item{hml84_frequency, hml84_log10fpm}{Raw frequency and log10 frequency
#'   per million of the phoneme in the Hoosier Mental Lexicon (Nusbaum, Pisoni,
#'   Pisoni, 1984) word-frequency dictionary.}
#'   \item{mhr82_frequency, mhr82_log10fpm}{Raw frequency and log10 frequency
#'   per million of the phoneme in the Moe, Hopkins, and Rush (1982) word
#'   frequency dictionary of first-graders.}
#' }
#'
#' ## Crowe and McLeod (2020) norms for English consonant acquisition
#'
#' Crowe and McLeod (2020, below as the `cm2020_` variables) provides a
#' systematic review and summary statistics for age of acquisition norms for
#' English consonants. They scoured the literature of acquisition ages for
#' individual consonants and computed summary statistics on them. They
#' considered just accuracy of sounds when produced in single words. Their
#' sources include a mix of a journal articles and norms for articulation
#' assessments. They do not weight statistics from individual studies by sample
#' size or sampling procedure.
#'
#' I prepared the Crowe and McLeod (2020) data by copying the relevant numbers
#' from their Table 2 making the following changes: 1) rounding mean and SD
#' values to 1 decimal point (3 days for ages in months), 2) dropping /ʍ/, 3)
#' using /r/, /g/, /tʃ/, /dʒ/ for IPA characters instead of the specialized
#' characters used in the article.
#'
#' ## English language phoneme frequencies
#'
#' The `hml84_frequency` column provides the frequency count for the phonemes in
#' the Hoosier Mental Lexicon (Nusbaum, Pisoni, Pisoni, 1984). That is, we count
#' how many times the phonemes appear in each word in the word list and weight
#' them by the word frequency. For example, "ad" has two phonemes and a corpus
#' frequency of 99, so it counts for 99 /æ/ tokens and 99 /d/ tokens.
#'
#' The HML frequency counts derive from the Brown Corpus of one million English
#' words that were printed/published in 1961. The HML provides frequencies of
#' *phonological* words, and homophones are combined into a single entry. For
#' example, the word "ad" has a frequency of 99 (11 *ad* tokens plus 88 *add*
#' tokens). That's why, I suppose, it's a *mental* lexicon. Approximately 8,000
#' words in the HML were not in the K&F frequency word list, and these are
#' apparently assigned a frequency of 1.
#'
#' The `mhr82_frequency` column was constructed in a similar way but the frequencies
#' were based on a corpus of words used by first-graders
#' (Moe, Hopkins, & Rush, 1982).
#'
#' The `hml84_log10fpm` and `mhr82_log10fpm` columns provide the frequency in log-10
#' frequency per million which is more appropriate for analyses. Computing
#' frequency per million normalize the frequency counts across different
#' corpora, and log-frequency is better suited than raw or normalized frequency
#' counts.
#'
#' I computed these phoneme frequencies independently, but retrieved my copies
#' of the HML and MHR frequency-pronunciation tables from [a
#' course](https://kb.osu.edu/items/6b1379d3-e15d-53e4-99b6-85f2bb09b3af) by
#' Smith, Beckman and Foltz (2016).
#'
#' ## The early 8, middle 8 and late 8 (Shriberg, 1993)
#'
#' The English consonants are often broken down into three developmental
#' classes, based on Shriberg (1993):
#'
#' - Early 8: m b j n w d p h
#' - Middle 8: t ŋ k g f v tʃ dʒ,
#' - Late 8: ʃ θ s z ð l r ʒ
#'
#' This classification is included as the `s93_eights` column.
#'
#' From these names alone, we might interpret these classes such that sounds in
#' the Early 8 would be acquired before the ones in the Middle 8, and likewise
#' that the Middle 8 would be acquired before the Late 8. But these classes were
#' not created by examining patterns of typical consonant acquisition.
#'
#' For some context, Shriberg (1993) introduces the Early 8, Middle 8, and Late
#' 8 data by describing the following panel of the article's Figure 7:
#'
#' ![First panel of Figure 7 from Shriberg (1993)](shriberg_1993_600.png)
#'
#' About which, Shriberg (1993) says:  _"The values for this trend, which is a
#' profile of consonant mastery, were taken from a group of 64 3- to 6-year-old
#' speech-delayed children Shriberg, Kwiatkowski, & Gruber, 1992). Severity of
#' involvement of the 24 English consonants is represented as the percentage
#' correct for each consonant sorted in decreasing order from left to right.
#' Notice that the most obvious breaks in this function allow for a division of
#' the 24 consonants into three groups of eight sounds termed the
#' **Early-8**, averaging over 75% correct, the **Middle-8**, averaging 25%-75%
#' correct, and the **Late-8**, including consonants averaging less than 25%
#' correct in continuous conversational speech (/ʒ/ is infrequently represented
#' in young, speech-delayed children's spontaneous conversational speech)."_
#'
#' So, there were 64 3--6-year-old children with speech delays, and consonant
#' sounds were divided into three classes based on how often *these
#' children* produced the sounds correctly on average in a conversational
#' speech sample. This classification is not so much a measure of the
#' relative ordering of speech sound development as it is **the relative
#' difficulty of these sounds for children with a speech delay of unknown
#' origin**. It would be more appropriate to replace the levels of
#' Early/Middle/Late with Easy/Medium/Hard.
#'
#' ## Phonetic complexity (Kent, 1992; Kuruvilla-Dugdale et al. 2018)
#'
#' Phonetic complexity measures (`k1992_set` and `kd2018_complexity`)
#' assign the speech sounds different complexity levels based on biological
#' principles outlined in Kent (1992). Because Kent (1992) is a book
#' chapter that is not floating around online, it's worthwhile to review
#' the provenance of these complexity measures. In short, Kent (1992) applied
#' interpreted consonant and vowel development data in terms of their
#' motor demands.
#'
#' Sander (1972) set out to construct a set of developmental norms for
#' typical consonant acquisition in English. His big idea was to include
#' the median age of acquisition as well as the 90th percentile age of
#' acquisition. The median can tell us something about the average
#' acquisition of the speech sounds, and the 90th percentile can set a
#' benchmark for delayed acquisition. There are some quirks of the
#' methodology. First, Sander (1972) was targeting "customary articulation"
#' which was defined using production accuracy average across word
#' positions. So, the age of 50% customary articulation for /t/ is the
#' earliest age when the average of word-initial accuracy, word-medial
#' accuracy and word-final accuracy is greater than 50%. Second, the norms
#' for this study were created by augmenting data from 3--8-year-olds
#' (Templin, 1957; *n* = 480) with some earlier data for 2-year-olds
#' (Wellman et al. 1931; *n* = 15).
#'
#' Sander (1972) presented these acquisition norms in the following figure:
#'
#' ![Figure 1 from Sander (1972)](sander_1972_400.png)
#'
#' Kent (1992) aimed to explain the course of English sound development in
#' terms of biological and motoric principles. He examined the ages of 90%
#' acquisition from Sander (1972)---that is, the right edges of the bars in
#' the previous figure---and observed that /p m n w h/ are mastered at
#' age 3, /b d k g j f/ at age 4, /t ŋ r l/ at age 6 and /s z ʃ ʒ v θ ð tʃ
#' dʒ/ after age 7. He then described motoric demands in each of these sets
#' of sounds. I'll paraphrase:
#'
#'   - Set 1 requires fast "ballistic" movements for stops /p m n/, slow
#'     "ramp" movements for /w h/, velopharyngeal control for oral-nasal
#'     contrast, laryngeal control for voicing contrast.
#'   - Set 2 adds more stops /b d k g/ and another ramp /j/ and a new place
#'     of articulation (velars), but also requires "fine force regulation
#'     for frication" for /f/.
#'   - Set 3 adds more stops /t ŋ/, but also requires tongue "bending" for
#'     /r/ and /l/.
#'   - Set 4 adds more lingual fricatives /s z ʃ ʒ θ ð/ which require
#'     tongue bending and fine force control along with /v tʃ dʒ/. Kent
#'     does not characterize the motor demands for the affricates /tʃ dʒ/.
#'
#' Let's pause for a moment and observe that this breakdown is just an
#' attempt to describe the Sander (1972) norms, and it is somewhat
#' underdeveloped. For example, why is /t/ in Set 3 but /d/ in Set 2? It is
#' not answered here, but I think this late mastery is an artefact of
#' Sander's requirement of 90% accuracy averaging over the three
#' word-positions. The medial and final productions of /t/ might require
#' allophonic variation in /t/ (e.g., flapping or glottalization), so
#' mastery of /t/ would require different motor gestures and some
#' phonological knowledge on the part of the child. But in Kent's
#' description /t/ is a later-mastered ballistic movement.
#'
#' Still, the main point of Kent's description, I think, is that lingual
#' (tongue) consonants are more difficult. Elsewhere in the chapter, Kent
#' (1992) describes how the tongue is a "muscular hydrostat" like an
#' elephant trunk, and bending a hydrostat requires coordination of
#' different muscle directions:
#'
#' *"Gaining motor control over a hydrostat presents some special problems
#' to the young child learning speech. For one, bending the hydrostat is
#' unlike bending a jointed structure such as a finger. The tongue has no
#' joints per se; it flexes by appropriate contraction of its
#' three-dimensional network of intrinsic longitudinal, vertical, and
#' transverse fibers. Bending a hydrostat requires that muscle fibers be
#' shortened on one aspect simultaneously with a resistance to a change in
#' diameter (Smith and Kier 1989). If the diameter change is not resisted,
#' then the hydrostat will shorten on one side but will not bend. To use
#' the tongue in speech, the child must learn to control the tongue to meet
#' skeletal, movement, and shaping requirements, often simultaneously.
#' These special characteristics of the tongue may well play a role in
#' vowel and consonant mastery."*
#'
#' Kim and colleagues (2010) applied these developmental sets (`k1992_set`) as
#' articulatory complexity *levels* while
#' examining consonant errors in dysarthric speech. They then asked
#' questions such as whether more complex consonants had more consonant
#' errors than less complex ones (*yes*) or whether lower intelligibility
#' speakers made more complexity-reducing consonant substitutions than
#' higher intelligibility speakers (*apparently so*). Examining the speech
#' of 5-year-olds, Allison and Hustad (2014) later used these complexity
#' levels as a way to *score* the phonetic complexity of sentences. They
#' assigned consonants 1--5 scores (the 1--4 complexity levels with a score
#' of 5 for consonants clusters), and summed up the scores to provide a
#' complexity score for a sentence. Three of the eight 5-year-olds with
#' dysarthria showed a negative effect of sentence complexity on
#' intelligibility.
#'
#' Kent (1992) also described the yearly developmental progression of
#' vowels. I'll paraphrase again:
#'
#'   - By age 1: Infants produce *vocants* (vowel precursors) which
#'     correspond to the low-front, central and low-back vowels /æ ɛ ʌ ə
#'     ɑ/. Thus, the tongue only moves in the anterior-posterior direction
#'     (i.e., there is limited up-down movement).
#'   - By age 2: Toddlers produce the "maximally dissimilar" corner vowels
#'     /i u ɑ/ and produce /o/ and the central vowels /ʌ ə/.
#'   - By age 3: Children incorporate two lower vowels /ɛ ɔ/ and the
#'     diphthongs /aɪ aʊ ɔɪ/ which require gliding movements.
#'   - By age 4: Children incorporate the remaining non-rhotic vowels /ʊ ɪ
#'     e æ/. The appearance of the front vowels suggests that tongue-jaw
#'     coordination is a relatively late motor achievement. (/i/ appears
#'     earlier because its extreme height is easy.)
#'   - Lastly: Children incorporate /ɚ ɝ/ last because these r-colored
#'     vowels require tongue bending.
#'
#' Kuruvilla-Dugdale and colleagues (2018) used this description to
#' incorporate vowels into the phonetic complexity scale
#' (`kd2018_complexity`). The /ʌ ə ɑ/ vocants from age 1 and the vowels
#' from age 2 mark the bottom of the complexity scale. The vowels that are
#' acquired at ages 3, 4 and afterwards are assigned to the consonant
#' complexity levels with the same age of mastery. Finally, consonant
#' clusters serve as the ceiling for the scale:
#'
#' ```{r, echo = FALSE}
#' df <- structure(
#'   list(
#'     kd2018_complexity = c(1, 2, 3, 4, 5, 6, 7, 8),
#'     consonants = c(
#'       "", "", "p m n h w", "b d k g f j", "t ŋ l r",
#'       "tʃ dʒ v θ ð s z ʃ ʒ", "2-consonant clusters", "3-consonant clusters"
#'     ),
#'     vowels = c(
#'       "ʌ ə ɑ", "i u oʊ", "ɛ ɔ aʊ aɪ ɔɪ", "ɪ eɪ æ ʊ", "ɝ ɚ",
#'       "", "", ""
#'     )
#'   ),
#'   row.names = c(NA, -8L),
#'   class = "data.frame"
#' )
#'
#' knitr::kable(df, caption = "Phonetic complexity scores from Kuruvilla-Dugdale et al. (2018).")
#' ```
#'
#' It is not clear how to apply this scale, so my approach has been to
#' break words into subsyllabic units and assign scores to the syllable
#' onsets, nucleui and codas in each word. For example, "jump" is /dʒ/ +
#' /ʌ/ + /mp/ so it would have complexity of 6 + 1 + 7 = 14, and "jumper"
#' includes a syllable break between the cluster, so it would have a
#' score 6 + 1 + 1 + 1 + 5 = 14.
#'
#' Kuruvilla-Dugdale and colleagues (2018) used this scoring system to
#' compare intelligibility for low complexity versus high complexity words.
#' For example, for speakers with ALS and mild dysarthria, there was
#' statistically clear reduction in intelligibility for high complexity
#' words but not for low complexity words. I applied this scoring system on
#' single-word intelligibility in children's speech (Mahr & Hustad, 2023).
#' There was a probable but not statistically clear negative effect of
#' complexity on intelligibility over and above the effects of age, word
#' frequency and word neighborhood competition. (Regrettably, I coded the
#' one consonant cluster in the word list with a complexity of 8 instead
#' of 7, but otherwise this is the approach.)
"data_acq_consonants"

#' @rdname data_acq_consonants
"data_acq_vowels"




#' Items from the TOCS+ used by the WISC Lab
#'
#' We use items from the Test of Children's Speech (TOCS+,
#' Hodge & Gotzke, 2014) in our child speech and listener intelligibility
#' studies.
#'
#' @format A data frame with 103 rows and 4 variables:
#' \describe{
#'   \item{tocs_type}{whether the item is a `single-word` or `multiword` utterance}
#'   \item{tocs_level}{number of words in the prompt}
#'   \item{tocs_item}{identifier for the item (e.g., within filenames)}
#'   \item{tocs_prompt}{the actual prompt presented to the child}
#'   \item{tocs_item_note}{any notes about an item's usage in experiments or analyses}
#' }
#' @concept datasets
#' @details Most of these items are subset from a larger pool of items on the TOCS+.
#' Hustad and colleagues (2021) is a supplemental material for a larger study
#' about speech intelligibility which describes where the items were taken from
#' within the larger TOCS+ task. (It is unclear, as I write this in 2026, which
#' items were added by our group to the TOCS+ pool, so I have added "possibly
#' not an original TOCS item" to items that do not appear in that supplemental
#' material.)
#'
#' In this picture-prompted repetition task, a child hears a *prompt*,
#' repeats it (*production*), and later on listeners transcribe it
#' (*transcription*). In our listener-response database, we differentiate these
#' three forms with fields named `tocs_prompt` (prompt), `sentence`
#' (production), and `response` (transcription).
#'
#' @references Hodge, M. M., & Gotzke, C. (2014). Construct-related validity of
#'   the TOCS+ measures: Comparison of intelligibility and speaking rate scores
#'   in children with and without speech disorders. *Journal of Communication
#'   Disorders*, *51*, 51–63. <https://doi.org/10.1016/j.jcomdis.2014.06.007>
#'
#'   Hustad, K. C., Mahr, T. J., Natzke, P., & Rathouz, P. J. (2021).
#'   Supplemental Material 1: Intelligibility growth between 30 and 119 months
#'   (Hustad et al., 2021) (Version 1). ASHA Journals.
#'   <https://doi.org/10.23641/asha.16583426.v1>
"data_tocs_items"


