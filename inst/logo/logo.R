title_font <- "Open Sans" # Added to R using extrafont package
url_font <- "Open Sans" # Added to R using extrafont package
temp <- "inst/logo/temp_sticker.png"
name_size <- 5
url_size <- 1.03
bg_color <- "#b3d7ff" # "#e6f2ff" is navbar bg
plot <- ggplot2::ggplot() +
  ggplot2::theme(panel.background = ggplot2::element_rect(fill = "transparent"),
                 plot.background = ggplot2::element_rect(fill = "transparent"),) +
  cowplot::draw_image(image = "inst/logo/logo_swisspalm(2).png", x = 0.2, y = 0.205, width = .6, height = .6)
sticker <- hexSticker::sticker(
  filename = temp,
  subplot = plot,
  s_x = 1, s_y = 1, s_height = 3, s_width = 3,
  package = "swisspalmR", p_size = name_size, p_fontface = "bold",
  p_x = 1, p_y = 0.8,  p_color = "#FFFFFF", p_family = title_font,
  h_size = 1.5, h_fill = bg_color, h_color = "grey20",
  url = "https://www.github.com/simpar1471/swisspalmR",
  u_x = 0.995, u_y = 0.06, u_size = url_size, u_angle = 30, u_family = url_font)
unlink(temp)
ggplot2::ggsave(sticker,
                filename = "man/figures/logo.png",
                height = 5.08, width = 4.39, units = "cm", type = "cairo")
usethis::use_logo(img = "man/figures/logo.png", geometry = "400x400")
