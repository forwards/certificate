#' Create certificates for all attendees
#'
#' @param attendees Names of attendees, character vector.
#' @param workshop Workshop title, character.
#' @param date Date of the workshop, as a date.
#' @param location Location of the workshop, character.
#' @param curriculum Path to the workshop curriculum (.md), character.
#' @param certifier Person certifying, character.
#' @param credentials Credentials of the certifying person, character.
#' @param organization Description of the organization running the workshops.
#' @param organization_url URL of the organization website, without https://.
#' @param dir Directory where to output the pdf certificates, character.
#' @param title Title for certificate.
#' @param action_text Action text between name and workshop title.
#' @param curriculum_title Header before curriculum content.
#' @param logo Specify the logo to use for the watermark, as a path to a logo
#' file or the name of a logo included in the package: either `"R"`
#' (default), or `"Forwards"`.
#' @param border_image Specify the image to use to create a border, as a path
#' to an image file. Defaults are used for the included logos: plain blue for
#' `logo = R` and a magma colour scale for `logo = "Forwards"`.
#' @param papersize Option for LaTeX article class specifying paper size, e.g.
#' `"a4paper"`, `"letterpaper"`.
#' @param keep_tex Logical argument passed to rmarkdown::render.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Fake names generated via charlatan::ch_name
#' attendees <- c("Marnie Dickinson", "Dr. Marlin Wilderman")
#' workshop <- "Package development workshop"
#' date <- as.Date("2018-01-01")
#' location <- "University of Lorraine"
#' curriculum <- system.file("rmarkdown", "templates",
#' "workshop_certificate", "resources",
#' "default_workshop_contents.md", package = "certificate")
#' certifier <- "Zaire Crooks"
#' credentials <- "Forwards teaching team member"
#' organization <- "Forwards, the R Foundation taskforce for women and other
#' under-represented groups"
#' organization_url <- "forwards.github.io/"
#' dir <- "certificates"
#' create_workshop_certificates(attendees, workshop, date, location,
#'                              curriculum, certifier, credentials,
#'                              organization, organization_url,
#'                              dir)
#' }
create_workshop_certificates <- function(attendees,
                                         workshop, date, location,
                                         curriculum, certifier, credentials,
                                         organization, organization_url,
                                         dir = ".",
                                         title = "CERTIFICATE OF COMPLETION",
                                         action_text = "participated in the",
                                         curriculum_title = "Workshop contents:",
                                         logo = "R", border_image = NULL,
                                         papersize = "a4paper",
                                         keep_tex = FALSE){

    if(!dir.exists(dir)){
        dir.create(dir)
    }

    temp_rmd <- copy_skeleton_file("skeleton.Rmd", dir)
    on.exit(file.remove(temp_rmd))

    temp_template <- copy_skeleton_file("template.tex", dir)
    on.exit(file.remove(temp_template), add = TRUE)

    if (!logo %in% c("R", "Forwards")) {
       temp_logo <- file.path(dir, "watermark.png")
       file.copy(logo, temp_logo)
    } else {
        logo_file <- switch(logo,
                            "Forwards" = "partly_transparent_forwards.png",
                            "Rlogo_50_percent_opacity.png")
        temp_logo <- copy_asset_file(logo_file, "watermark.png", dir)
    }
    on.exit(file.remove(temp_logo), add = TRUE)

    if (!is.null(border_image)){
        temp_border <- file.path(dir, "border.pdf")
        file.copy(border_image, temp_border)
        on.exit(file.remove(temp_border), add = TRUE)
    } else if (logo == "Forwards"){
        temp_border <- copy_asset_file("magma_border.pdf", "border.pdf", dir)
        on.exit(file.remove(temp_border), add = TRUE)
    } else temp_border <- NULL

    purrr::walk2(attendees, 1:length(attendees),
                 create_workshop_certificate,
                 title = title,
                 action_text = action_text,
                 workshop, date, location,
                 curriculum_title = curriculum_title,
                 curriculum,
                 certifier, credentials,
                 organization = organization,
                 organization_url = organization_url,
                 border_image = temp_border,
                 papersize, dir,
                 keep_tex)
}

# https://tex.stackexchange.com/questions/346730/fancyhdr-package-not-working
create_workshop_certificate <- function(attendee, number,
                                        title = "CERTIFICATE OF COMPLETION",
                                        action_text = "participated in the",
                                        workshop, date, location,
                                        curriculum_title = "Workshop contents:",
                                        curriculum,
                                        certifier, credentials,
                                        organization = "R Contribution Working Group\n",
                                        organization_url = "contributor.r-project.org",
                                        border_image = NULL,
                                        papersize = "a4paper", dir = ".",
                                        keep_tex = FALSE){
    i <- stringr::str_pad(number, 2, pad = "0")
    output_file <- paste0(snakecase::to_snake_case(paste(workshop, i)), ".pdf")
    rmarkdown::render(input = file.path(dir, "skeleton.Rmd"),
                      output_file = output_file,
                      output_dir = dir,
                      params = list(title = title,
                                    attendee = attendee,
                                    action_text = action_text,
                                    workshop = workshop,
                                    date = date,
                                    location = location,
                                    curriculum_title = curriculum_title,
                                    curriculum = curriculum,
                                    certifier = certifier,
                                    credentials = credentials,
                                    organization = organization,
                                    organization_url = organization_url,
                                    border_image = border_image,
                                    papersize = papersize),
                      output_options = list(keep_tex = keep_tex),
                      clean = TRUE)
}

copy_package_file <- function(old_file, old_dir, new_file, new_dir){
    new_path <- file.path(new_dir, new_file)
    file.copy(system.file(old_dir, old_file, package = "certificate"),
              new_path)
    new_path
}

copy_skeleton_file <- function(file, new_dir){
    copy_package_file(file,
                      file.path("rmarkdown", "templates",
                                "workshop_certificate", "skeleton"),
                      file, new_dir)
}

copy_asset_file <- function(file, new_file, new_dir){
    copy_package_file(file,
                      file.path("extdata", "assets"),
                      new_file, new_dir)
}
