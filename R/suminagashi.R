#' Make suminagashi-style topographic map art
#' 
#' @param elev An elevation raster object of the mapping area
#' @param xlim Limits for x-axis, format c(xmin, xmax)
#' @param ylim Limits for y-axis, format c(ymin, ymax)
#' @param pal_breaks Breaks in contours for palette
#' @param pal Colour palette for contours; repeated if shorter than `pal_breaks`
#' @param file_name Optional: file name and extension
#' 
#' @rdname suminagashi
#' @export
suminagashi <- function(
    elev, 
    xlim, ylim,
    pal_breaks,
    pal,
    a = 1,
    file_name,
    hb = FALSE
) {
  
  elev_df <- data.frame(raster::rasterToPoints(elev)) |> 
    dplyr::rename_with(.cols = -c(x, y), .fn = ~ "z") |> 
    dplyr::filter(
      x >= min(xlim), x <= max(xlim),
      y >= min(ylim), y <= max(ylim)
    )
  
  pal_breaks <- sort(unique(pal_breaks))
  
  g <- elev_df |> 
    ggplot2::ggplot(ggplot2::aes(x = x, y = y)) +
    # Contours
    ggplot2::geom_contour_filled(
      ggplot2::aes(z = z),
      col = NA,
      breaks = pal_breaks,
      alpha = a,
      show.legend = FALSE
    ) +
    # Palette
    scale_fill_suminagashi(pal = pal, breaks = pal_breaks) +
    # Other formatting
    ggplot2::coord_equal(xlim = xlim, ylim = ylim) +
    ggplot2::labs(x = "", y = "") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.line = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(fill = "transparent", colour = NA),
      plot.background  = ggplot2::element_rect(fill = "transparent", colour = NA)
    )
  
  if(!missing(file_name)) {
    
    ggplot2::ggsave(
      here::here(file_name),
      width = 210, height = 297, units = "mm",
      dpi = 600
    )
    
  }
  
  if(hb) {
    message("Happy birthday!")
  }
  
  return(g)
  
}




#' Define colour palette for elevation map
#' 
#' @param breaks Breaks in contours
#' @param pal Colour palette
#' 
#' @export
scale_fill_suminagashi <- function(
    breaks,
    pal = NULL
) {
  
  # If no palette is defined, use a tomato!
  if(is.null(pal)) {
    pal <- c("white", "tomato")
  }
  
  len_brk <- length(breaks)
  len_pal <- length(pal)
  if(len_brk <= len_pal) {
    pal_values <- pal[1:len_brk]
  } else if(len_brk %% len_pal == 0) {
    pal_values <- rep(pal, len_brk %/% len_pal)
  } else {
    pal_values <- c(
      rep(pal, len_brk %/% len_pal),
      pal[1:len_brk %/% len_pal]
    )
  }
  
  out <- ggplot2::scale_fill_manual(
    values = pal_values, na.value = NA
  )
  return(out)
  
}

