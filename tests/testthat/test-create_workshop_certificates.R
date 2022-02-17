context("test-create_workshop_certificates.R")

test_that("create_workshop_certificates works", {
    skip_on_cran()
    attendees <- c("Marnie Dickinson", "Dr. Marlin Wilderman")
    date <- structure(17532, class = "Date")
    location <- "University of Barcelona"
    workshop <- "Package development workshop"
    curriculum <- system.file("rmarkdown", "templates", "workshop_certificate", "resources", "default_workshop_contents.md", package = "fwdbrand")
    certifier <- "Zaire Crooks"
    credentials <- "Forwards teaching team member"
    dir <- "certificates"
    create_workshop_certificates(date, location,
                                 workshop, curriculum, certifier,
                                 credentials,
                                 attendees,
                                 dir)
    expect_true(file.exists(file.path(dir,
                                      "package_development_workshop_01.pdf")))
    expect_true(file.exists(file.path(dir,
                                      "package_development_workshop_02.pdf")))

    text <- pdftools::pdf_text(file.path(dir,
                                         "package_development_workshop_01.pdf"))
    expect_true(grepl("Zaire Crooks", text))
    expect_true(grepl("CERTIFICATE OF COMPLETION", text))
    expect_true(grepl("University of Barcelona", text))
    expect_true(grepl("Marnie Dickinson", text))
    expect_true(grepl("2018-01-01", text))
    expect_true(grepl("Package development workshop", text))
    expect_true(grepl("Collaborative", text))
    expect_true(grepl("forwards\\.github\\.io", text))
    unlink(dir, recursive = TRUE)

    dir <- "certificates"
    create_workshop_certificates(date, location, workshop, curriculum, certifier,
                                 credentials,
                                 attendees,
                                 dir, keep_tex = TRUE)
    expect_true(file.exists(file.path(dir,
                                      "package_development_workshop_01.tex")))
    expect_true(file.exists(file.path(dir,
                                      "package_development_workshop_02.tex")))
    unlink(dir, recursive = TRUE)
})
