# TightSenseClustering

TightSenseClustering is a wrapper for the open source project: Clinical Abbreviation Recognition and Disambiguation (CARD), available here https://sbmi.uth.edu/ccb/resources/abbreviation.htm. This directory contains modified file I/O methods in the class [SenseDisambiguationText](TightClusteringSenseDetection/bin/MetaMapWrapper/SenseDisambiguationText.class) and is published here with permission from the authors. `SenseDisambiguationText.class` was re-interpreted in order to facilitate input streams from `stdin` and `stdout` to enable piping of bytes from memory instead of from disk.

## Usage:
To test the implementation perform the following steps.

1. `cd TightSenseClustering_v2`
1. `echo "the pt walked in to the clinic, 1 h" | java -cp ./bin MetaMapWrapper.SenseDisambiguationText`

You should see the following output on the console:

```
BEGIN_SENTENCE:
the pt walked in to the clinic , 1 h
Abbr:	pt	pt	patient	C0030705	podg
Abbr:	h	h	hours	C0439227	tmco
END_SENTENCE.
```

You can perform the same test using the `.jar` file:

1. `cd TightSenseClustering_v2`
1. `echo "the pt walked into the clinic, 1 h" | java -cp TightSenseTightSenseClustering.jar:bin/ MetaMapWrapper.SenseDisambiguationText`



## Citations:

1. Wu Y, Rosenbloom ST, Denny JC, Miller RA, Mani S, Giuse DA, Xu H. Detecting abbreviations in discharge summaries using machine learning methods. AMIA Annu Symp Proc. 2011, 1541-9. [PMCID: PMC3243185]
1. yonghuiwu / card — Bitbucket [Internet]. [cited 2019 Jun 12]. Available from: https://bitbucket.org/yonghuiwu/card/src/master/
1. Wu Y, Denny JC, Trent Rosenbloom S, Miller RA, Giuse DA, Wang L, et al. A long journey to short abbreviations: developing an open-source framework for clinical abbreviation recognition and disambiguation (CARD). J Am Med Inform Assoc. 2017 Apr 1;24(e1):e79–86.
1. Wu Y, Rosenbloom ST, Denny JC, Miller RA, Mani S, Giuse DA, et al. Detecting Abbreviations in Discharge Summaries using Machine Learning Methods. AMIA Annu Symp Proc. 2011;2011:1541–9.
1. Xu H, Stetson PD, Friedman C. Methods for Building Sense Inventories of Abbreviations in Clinical Notes. J Am Med Inform Assoc. 2009 Jan 1;16(1):103–8.
