#' Create certificates for all attendees
#'
#' @param title Title for certificate.
#' @param attendees Names of attendees, character vector.
#' @param action_text Action text between name and workshop title.
#' @param workshop Workshop title, character.
#' @param date Date of the workshop, as a date.
#' @param location Location of the workshop, character.
#' @param curriculum_title Header before curriculum content.
#' @param curriculum Text string describing the workshop curriculum.
#' @param curriculum_file Path to the workshop curriculum (.md), character.
#' @param certifier Person certifying, character.
#' @param credentials Credentials of the certifying person, character.
#' @param organization Decription of the organization running the workshops.
#' @param organization_url URL of the organization website, without https://.
#' @param logo Specify the logo to use for the watermark, either `"R"`
#' (default), or `"Forwards"`.
#' @param papersize Option for LaTeX article class specifying paper size, e.g.
#' `"a4paper"`, `"letterpaper"`.
#' @param dir Directory where to output the pdf certificates, character.
#' @param keep_tex Logical argument passed to rmarkdown::render.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Fake names generated via charlatan::ch_name
#' attendees <- c("Marnie Dickinson", "Dr. Marlin Wilderman")
#' date <- as.Date("2018-01-01")
#' location <- "University of Lorraine"
#' workshop <- "Package development workshop"
#' curriculum <- system.file("rmarkdown", "templates",
#' "workshop_certificate", "resources",
#' "default_workshop_contents.md", package = "certificate")
#' certifier <- "Zaire Crooks"
#' credentials <- "Forwards teaching team member"
#' dir <- "certificates"
#' create_workshop_certificates(date, location, workshop, curriculum,
#'  certifier,
#' credentials,
#' attendees,
#' dir)
#' }
create_workshop_certificates <- function(title = "CERTIFICATE OF COMPLETION",
                                         attendees,
                                         action_text = "participated in the",
                                         workshop, date, location,
                                         curriculum_title = "Workshop contents:",
                                         curriculum, curriculum_file = NULL,
                                         certifier, credentials,
                                         organization = "R Contribution Working Group\n",
                                         organization_url = "contributor.r-project.org",
                                         logo = "R", papersize = "a4paper",
                                         dir = ".", keep_tex = FALSE){

    if(!dir.exists(dir)){
        dir.create(dir)
    }

    temp_rmd <- copy_skeleton_file("skeleton.Rmd", dir)
    on.exit(file.remove(temp_rmd))

    temp_template <- copy_skeleton_file("template.tex", dir)
    on.exit(file.remove(temp_template), add = TRUE)

    logo <- match.arg(logo, c("R", "Forwards"))
    logo_file <- switch(logo,
                        "Forwards" = "partly_transparent_forwards.png",
                        "Rlogo_50_percent_opacity.png")
    temp_logo <- copy_asset_file(logo_file, "watermark.png", dir)
    on.exit(file.remove(temp_logo), add = TRUE)

    if (logo == "Forwards"){
        temp_border <- copy_asset_file("magma_border.pdf", "border.pdf", dir)
        on.exit(file.remove(temp_border), add = TRUE)
    }

    purrr::walk2(attendees, 1:length(attendees),
                 create_workshop_certificate,
                 title = title,
                 action_text = action_text,
                 workshop, date, location,
                 curriculum_title = curriculum_title,
                 curriculum,
                 curriculum_file = curriculum_file,
                 certifier, credentials,
                 organization = organization,
                 organization_url = organization_url,
                 logo == "Forwards", papersize, dir,
                 keep_tex)
}

# https://tex.stackexchange.com/questions/346730/fancyhdr-package-not-working
create_workshop_certificate <- function(attendee, number,
                                        title = "CERTIFICATE OF COMPLETION",
                                        action_text = "participated in the",
                                        workshop, date, location,
                                        curriculum_title = "Workshop contents:",
                                        curriculum, curriculum_file = NULL,
                                        certifier, credentials,
                                        organization = "R Contribution Working Group\n",
                                        organization_url = "contributor.r-project.org",
                                        border_image = FALSE,
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
                                    curriculum_file = curriculum_file,
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
