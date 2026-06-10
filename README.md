# rk.word.cloud

![Version](https://img.shields.io/badge/Version-0.0.1-blue.svg)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.word.cloud/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.word.cloud/actions/workflows/lintr.yml)
![AI Gemini](https://img.shields.io/badge/AI-Gemini-4285F4?logo=googlegemini&logoColor=white)

**An RKWard GUI Plugin for Beautiful and Customizable Word Clouds**

`rk.word.cloud` provides a seamless, point-and-click graphical interface inside RKWard to create visually stunning word clouds from text mining data. Acting as a unified GUI wrapper for the [`ggwordcloud`](https://cran.r-project.org/package=ggwordcloud), [`tm`](https://cran.r-project.org/package=tm), and [`ggplot2`](https://cran.r-project.org/package=ggplot2) packages, this plugin allows users to effortlessly turn a raw text Corpus into a publication-ready graphic without writing any R code.

This package serves as the perfect visual companion to the `rk.text.mining` package, completing the NLP workflow from data cleaning to graphical output.

---

## 🌟 Key Features

* **Zero-Code Word Clouds:** Generate plots directly from a standard `tm` Corpus object.
* **RAM-Optimized Processing:** Uses `slam` to safely and efficiently parse massive Term-Document Matrices without crashing R.
* **Advanced Customization:** Choose from multiple shapes (Circle, Heart, Star, Diamond, Triangle), rotation patterns (Classic, Chaotic), and ColorBrewer palettes.
* **One-Click Dark Mode:** Instantly invert the background to black and the theme to minimal to make neon color palettes (like *Spectral*) pop.
* **On-the-Fly Filtering:** Define a Top-N word limit, set a minimum frequency threshold, and drop specific stopwords directly from the interface.
* **Standalone Export:** Save your word cloud natively as a high-resolution PNG, SVG, or JPG directly from the Output tab.
* **Multilingual:** Fully translated into English, Spanish, French, German, and Portuguese (Brazil).

---

## ⚙️ Prerequisites

You must have [RKWard](https://rkward.kde.org/) installed along with the following R packages:

```R
install.packages(c("tm", "slam", "ggplot2", "ggwordcloud", "RColorBrewer"))
```

---

## 🚀 Installation

You can install this plugin directly from GitHub using `devtools`:

```R
# Install the plugin
devtools::install_github("AlfCano/rk.word.cloud")
```

Once installed, open RKWard, navigate to **Settings -> Configure RKWard -> Plugins**, and activate `rk.word.cloud`.

---

## 🛠️ Usage Workflow

This plugin adds a new tool to RKWard under the **Plots -> Text Mining** menu called **Generate Word Cloud**. 

1. **Data Input:** Select your clean text Corpus. Set your minimum frequency limits and type any last-minute words you want to exclude.
2. **Appearance:** Select the shape of the cloud, color palette, word rotation style, and toggle the Dark Mode.
3. **Output & Export:** Preview the map instantly or configure the dimensions to export it as a high-resolution PNG or SVG image.

---

## 🧪 The Testing Workflow

To test the plugin and see how it automatically counts and renders words, follow this step-by-step guide. First, paste this into the RKWard console to create a mock text Corpus:

```r
# Create a Mock Text Corpus
library(tm)

texts <- c(
  "RKWard is amazing for GUI data science.",
  "Text mining in RKWard is easy and fun.",
  "Data science requires good GUI tools like RKWard.",
  "Word clouds are fun to make with ggwordcloud and ggplot2.",
  "RKWard GUI makes R programming easy, fast, and amazing.",
  "Data mining and text mining are fun."
)

mock_corpus <- VCorpus(VectorSource(texts))
mock_corpus <- tm_map(mock_corpus, content_transformer(tolower))
mock_corpus <- tm_map(mock_corpus, removePunctuation)
```

**Step-by-step Test:**

1.  **Open `Plots > Text Mining > Generate Word Cloud`**
2.  **Data Input Tab:**
    *   *Text Corpus:* Select `mock_corpus`
    *   *Maximum words to display:* Keep at `150`
    *   *Minimum word frequency:* Set to `1`
    *   *Extra Stopwords:* Type `and, for, with, are, like`
3.  **Appearance Tab:**
    *   *Cloud Shape:* Select `Star`
    *   *Color Palette:* Select `Spectral (Highly Recommended)`
    *   *Dark Mode:* Check the box.
4.  **Output & Export Tab:**
    *   Click **Submit**.

**Result:** A stunning, high-definition word cloud will appear in your RKWard output window (and graphics device) featuring a black background, a star-shaped layout, and words colored by frequency using the Spectral palette, with "rkward", "mining", "data", and "fun" standing out as the largest words!

---

## 🌍 Internationalization (i18n)

The graphical interface automatically adapts to your RKWard language settings. Currently supported languages:
* 🇺🇸 English (Default)
* 🇪🇸 Spanish (Español)
* 🇫🇷 French (Français)
* 🇩🇪 German (Deutsch)
* 🇧🇷 Portuguese (Português do Brasil)

---

## 📝 License and Author

**Author:** Alfonso Cano ([@AlfCano](https://github.com/AlfCano))  
**Email:** alfonso.cano@correo.buap.mx  
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)

This project is licensed under the **GPL (>= 3)** License.
