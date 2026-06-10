// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	preprocess(true);
	calculate(true);
	printout(true);
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(tm)){stop(" + i18n("Preview not available, because package tm is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(tm)\n");
	}	if(is_preview) {
		echo("if(!base::require(ggplot2)){stop(" + i18n("Preview not available, because package ggplot2 is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(ggplot2)\n");
	}	if(is_preview) {
		echo("if(!base::require(ggwordcloud)){stop(" + i18n("Preview not available, because package ggwordcloud is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(ggwordcloud)\n");
	}	if(is_preview) {
		echo("if(!base::require(RColorBrewer)){stop(" + i18n("Preview not available, because package RColorBrewer is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(RColorBrewer)\n");
	}	if(is_preview) {
		echo("if(!base::require(slam)){stop(" + i18n("Preview not available, because package slam is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(slam)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return "NULL";
        return raw.split("$").pop();
    }
  
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

    echo("require(tm)\n");
    echo("require(slam)\n");
    echo("require(ggplot2)\n");
    echo("require(ggwordcloud)\n\n");

    echo("# 1. Convert Corpus to TDM and get frequencies safely (avoiding RAM limits)\n");
    echo("tdm <- tm::TermDocumentMatrix(" + corpus + ")\n");
    echo("word_freqs <- sort(slam::row_sums(tdm), decreasing = TRUE)\n");
    echo("df_words <- data.frame(word = names(word_freqs), freq = word_freqs, stringsAsFactors = FALSE)\n\n");

    echo("# 2. Apply filters\n");
    echo("df_words <- df_words[df_words$freq >= " + minfreq + ", ]\n");
    if (stopwords !== "") {
        echo("custom_stops <- unlist(strsplit(\"" + stopwords + "\", \",\\\\s*\"))\n");
        echo("df_words <- df_words[!df_words$word %in% custom_stops, ]\n");
    }
    echo("df_words <- head(df_words, n = " + topn + ")\n\n");

    echo("# 3. Word Rotation\n");
    if (rot === "horizontal") {
        echo("df_words$angle <- 0\n");
    } else if (rot === "classic") {
        echo("df_words$angle <- 90 * sample(c(0, 1), nrow(df_words), replace = TRUE, prob = c(0.7, 0.3))\n");
    } else {
        echo("df_words$angle <- 45 * sample(-2:2, nrow(df_words), replace = TRUE)\n");
    }

    echo("\n# 4. Generate Plot\n");
    echo("p <- ggplot2::ggplot(df_words, ggplot2::aes(label = word, size = freq, color = freq, angle = angle)) +\n");
    echo("  ggwordcloud::geom_text_wordcloud_area(shape = \"" + shape + "\", rm_outside = TRUE) +\n");
    echo("  ggplot2::scale_size_area(max_size = " + s_max + ") +\n");

    echo("  ggplot2::scale_color_gradientn(colors = colorRampPalette(RColorBrewer::brewer.pal(8, \"" + pal + "\"))(10)) +\n");

    if (dark === "1") {
        echo("  ggplot2::theme_minimal() +\n");
        echo("  ggplot2::theme(plot.background = ggplot2::element_rect(fill = \"black\", color = \"black\"), panel.background = ggplot2::element_rect(fill = \"black\", color = \"black\"))\n");
    } else {
        echo("  ggplot2::theme_minimal()\n");
    }
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Create a Word Cloud results")).print();	
	}
    if(is_preview){
        echo("try(print(p))\n");
    } else {
        var dev_type = getValue("device_type");
        var w = getValue("dev_width");
        var h = getValue("dev_height");
        var res = getValue("dev_res");

        var bg = getValue("dev_bg");
        if (bg === "auto") {
            bg = (getValue("chk_dark") === "1") ? "black" : "white";
        }

        echo("try(rk.graph.on(device.type=\"" + dev_type + "\", width=" + w + ", height=" + h + ", res=" + res + ", bg=\"" + bg + "\"))\n");
        echo("try(print(p))\n");
        echo("try(rk.graph.off())\n");
    }
  
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var savePlotObj = getValue("save_plot_obj");
		var savePlotObjActive = getValue("save_plot_obj.active");
		var savePlotObjParent = getValue("save_plot_obj.parent");
		// assign object to chosen environment
		if(savePlotObjActive) {
			echo(".GlobalEnv$" + savePlotObj + " <- p\n");
		}	
	}

}

