local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  plugin_name <- "rk.word.cloud"

  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "Generate beautiful, customizable word clouds using ggwordcloud from tm Corpus objects.",
      version = "0.0.1",
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/AlfCano/rk.word.cloud",
      license = "GPL (>= 3)"
    )
  )

  dependencies_node <- rk.XML.dependencies(
    dependencies = list(R.min = "3.5.0"),
    package = list(
      c(name = "tm"),
      c(name = "slam"),
      c(name = "ggplot2"),
      c(name = "ggwordcloud"),
      c(name = "RColorBrewer")
    )
  )

  # JS Helper to extract object names cleanly
  js_helpers <- '
    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return "NULL";
        return raw.split("$").pop();
    }
  '

  # =========================================================================================
  # 2. UI Components
  # =========================================================================================

  # --- Tab 1: Data Input ---
  var_sel <- rk.XML.varselector(id.name = "v_sel_corpus")

  # Acepta cualquier objeto en el entorno, pero la etiqueta guía al usuario a usar el Corpus
  inp_corpus <- rk.XML.varslot(label = "Text Corpus (tm object from rk.text.mining)", source = "v_sel_corpus", required = TRUE, id.name = "inp_corpus")

  spin_topn <- rk.XML.spinbox(label = "Maximum words to display (Top N)", id.name = "spin_topn", min = 10, max = 2000, initial = 150)
  spin_minfreq <- rk.XML.spinbox(label = "Minimum word frequency", id.name = "spin_minfreq", min = 1, max = 5000, initial = 2)

  inp_stopwords <- rk.XML.input(label = "Extra Stopwords to remove (comma separated, e.g., 'said, the, also')", id.name = "inp_stopwords", required = FALSE)

  tab1_data <- rk.XML.col(inp_corpus, spin_topn, spin_minfreq, inp_stopwords, rk.XML.stretch())

  # --- Tab 2: Appearance & Shapes ---
  drop_shape <- rk.XML.dropdown(label = "Cloud Shape", id.name = "drop_shape", options = list(
    "Circle (Default)" = list(val = "circle", chk = TRUE),
    "Cardioid / Heart" = list(val = "cardioid"),
    "Diamond" = list(val = "diamond"),
    "Triangle" = list(val = "triangle-forward"),
    "Pentagon" = list(val = "pentagon"),
    "Star" = list(val = "star")
  ))

  drop_pal <- rk.XML.dropdown(label = "Color Palette", id.name = "drop_pal", options = list(
    "Spectral (Highly Recommended)" = list(val = "Spectral", chk = TRUE),
    "Dark2" = list(val = "Dark2"),
    "Set1" = list(val = "Set1"),
    "Set2" = list(val = "Set2"),
    "Paired" = list(val = "Paired"),
    "Blues" = list(val = "Blues"),
    "Reds" = list(val = "Reds")
  ))

  drop_rot <- rk.XML.dropdown(label = "Word Rotation", id.name = "drop_rot", options = list(
    "Horizontal Only (Clean)" = list(val = "horizontal", chk = TRUE),
    "Classic (Horizontal & 90° Vertical)" = list(val = "classic"),
    "Chaotic (Random Angles)" = list(val = "chaotic")
  ))

  chk_dark <- rk.XML.cbox(label = "Dark Mode (Black Background)", value = "1", un.value = "0", id.name = "chk_dark")

  frame_sizes <- rk.XML.frame(label = "Word Size Settings", child = rk.XML.row(
    rk.XML.spinbox(label = "Min Size", id.name = "spin_size_min", min = 1, max = 20, initial = 3),
    rk.XML.spinbox(label = "Max Size", id.name = "spin_size_max", min = 5, max = 60, initial = 15)
  ))

  tab2_app <- rk.XML.col(drop_shape, drop_pal, drop_rot, chk_dark, frame_sizes, rk.XML.stretch())

  # --- Tab 3: Output Device (Export) ---
  export_frame <- rk.XML.frame(label = "Graphics Export Settings",
      rk.XML.dropdown(label = "Device type", id.name = "device_type", options = list("PNG" = list(val = "PNG", chk = TRUE), "SVG" = list(val = "SVG"), "JPG" = list(val = "JPG"))),
      rk.XML.row(rk.XML.spinbox(label = "Width (px)", id.name = "dev_width", min = 100, max = 4000, initial = 1200), rk.XML.spinbox(label = "Height (px)", id.name = "dev_height", min = 100, max = 4000, initial = 1000)),
      rk.XML.col(rk.XML.spinbox(label = "Resolution (ppi)", id.name = "dev_res", min = 50, max = 600, initial = 150), rk.XML.dropdown(label = "Background Override", id.name = "dev_bg", options = list("Follow Dark Mode settings" = list(val = "auto", chk = TRUE), "Transparent" = list(val = "transparent"), "White" = list(val = "white"))))
  )

  save_plot <- rk.XML.saveobj(label = "Save Plot Object", initial = "p", id.name = "save_plot_obj", chk = TRUE)
  preview_map <- rk.XML.preview(mode = "plot", id.name = "preview_wc")
  tab3_out <- rk.XML.col(export_frame, save_plot, preview_map)

  # --- Dialog Assembly ---
  main_tabbook <- rk.XML.tabbook(tabs = list(
    "Data Input" = tab1_data,
    "Appearance" = tab2_app,
    "Output & Export" = tab3_out
  ))

  dialog_wc <- rk.XML.dialog(label = "Generate Word Cloud", child = rk.XML.row(var_sel, main_tabbook))

  # =========================================================================================
  # 3. JavaScript Generation
  # =========================================================================================

js_calc <- paste0(js_helpers, '
    var corpus = getValue("inp_corpus");
    if (!corpus) return;

    var topn = getValue("spin_topn");
    var minfreq = getValue("spin_minfreq");
    var stopwords = getValue("inp_stopwords");
    var shape = getValue("drop_shape");
    var pal = getValue("drop_pal");
    var rot = getValue("drop_rot");
    var dark = getValue("chk_dark");
    var s_min = getValue("spin_size_min");
    var s_max = getValue("spin_size_max");

    echo("require(tm)\\n");
    echo("require(slam)\\n");
    echo("require(ggplot2)\\n");
    echo("require(ggwordcloud)\\n\\n");

    echo("# 1. Convert Corpus to TDM and get frequencies safely\\n");
    echo("tdm <- tm::TermDocumentMatrix(" + corpus + ")\\n");
    echo("word_freqs <- sort(slam::row_sums(tdm), decreasing = TRUE)\\n");
    echo("df_words <- data.frame(word = names(word_freqs), freq = word_freqs, stringsAsFactors = FALSE)\\n\\n");

    echo("# 2. Apply filters\\n");
    echo("df_words <- df_words[df_words$freq >= " + minfreq + ", ]\\n");
    if (stopwords !== "") {
        echo("custom_stops <- unlist(strsplit(\\"" + stopwords + "\\", \\",\\\\\\\\s*\\"))\\n");
        echo("df_words <- df_words[!df_words$word %in% custom_stops, ]\\n");
    }

    echo("if(nrow(df_words) == 0) stop(\\"¡Error! No hay palabras que cumplan con la frecuencia mínima. Intenta bajar el filtro.\\")\\n\\n");

    echo("df_words <- head(df_words, n = " + topn + ")\\n\\n");

    echo("# 3. Word Rotation\\n");
    if (rot === "horizontal") {
        echo("df_words$angle <- 0\\n");
    } else if (rot === "classic") {
        echo("df_words$angle <- 90 * sample(c(0, 1), nrow(df_words), replace = TRUE, prob = c(0.7, 0.3))\\n");
    } else {
        echo("df_words$angle <- 45 * sample(-2:2, nrow(df_words), replace = TRUE)\\n");
    }

    echo("\\n# 4. Generate Plot\\n");
    echo("p <- ggplot2::ggplot(df_words, ggplot2::aes(label = word, size = freq, color = freq, angle = angle)) +\\n");

    // FIX: rm_outside = FALSE to prevent crash in small preview windows
    echo("  ggwordcloud::geom_text_wordcloud_area(shape = \\"" + shape + "\\", rm_outside = FALSE) +\\n");

    echo("  ggplot2::scale_size_area(max_size = " + s_max + ") +\\n");
    echo("  ggplot2::scale_color_gradientn(colors = colorRampPalette(RColorBrewer::brewer.pal(8, \\"" + pal + "\\"))(10)) +\\n");

    if (dark === "1") {
        echo("  ggplot2::theme_minimal() +\\n");
        echo("  ggplot2::theme(plot.background = ggplot2::element_rect(fill = \\"black\\", color = \\"black\\"), panel.background = ggplot2::element_rect(fill = \\"black\\", color = \\"black\\"))\\n");
    } else {
        echo("  ggplot2::theme_minimal()\\n");
    }
  ')

  js_print <- '
    if(is_preview){
        echo("try(print(p))\\n");
    } else {
        var dev_type = getValue("device_type");
        var w = getValue("dev_width");
        var h = getValue("dev_height");
        var res = getValue("dev_res");

        var bg = getValue("dev_bg");
        if (bg === "auto") {
            bg = (getValue("chk_dark") === "1") ? "black" : "white";
        }

        echo("try(rk.graph.on(device.type=\\"" + dev_type + "\\", width=" + w + ", height=" + h + ", res=" + res + ", bg=\\"" + bg + "\\"))\\n");
        echo("try(print(p))\\n");
        echo("try(rk.graph.off())\\n");
    }
  '


  # =========================================================================================
  # 4. Final Skeleton Assembly
  # =========================================================================================
  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = dialog_wc),
    js = list(require = c("tm", "ggplot2", "ggwordcloud", "RColorBrewer", "slam"),
    calculate = js_calc,
    printout = js_print),
    pluginmap = list(name = "Create a Word Cloud", hierarchy = list("plots", "Word Cloud")),
    dependencies = dependencies_node,
    create = c("pmap", "xml", "js", "desc", "rkh"),
    overwrite = TRUE,
    load = TRUE
  )
})
