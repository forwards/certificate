context("test-create_workshop_certificates.R")

test_that("create_workshop_certificates works", {
    skip_on_cran()
    attendees <- c("Marnie Dickinson", "Dr. Marlin Wilderman")
    workshop <- "Package development workshop"
    date <- structure(17532, class = "Date")
    location <- "University of Barcelona"
    curriculum <- system.file("rmarkdown", "templates", "workshop_certificate",
                              "resources", "default_workshop_contents.md",
                              package = "certificate")
    certifier <- "Zaire Crooks"
    credentials <- "Forwards teaching team member"
    organization <- "Forwards, the R Foundation taskforce for women and other
    under-represented groups"
    organization_url <- "forwards.github.io/"
    dir <- "certificates"
    create_workshop_certificates(attendees,
                                 workshop, date, location,
                                 curriculum, certifier, credentials,
                                 organization, organization_url,
                                 dir)
    nm <- c("package_development_workshop_marnie_dickinson",
            "package_development_workshop_dr_marlin_wilderman")
                 tolower
    expect_true(file.exists(file.path(dir, paste0(nm[1], ".pdf"))))
    expect_true(file.exists(file.path(dir, paste0(nm[2], ".pdf"))))

    text <- pdftools::pdf_text(file.path(dir, paste0(nm[1], ".pdf"))))
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
    create_workshop_certificates(attendees,
                                 workshop, date, location,
                                 curriculum, certifier, credentials,
                                 organization, organization_url,
                                 dir, keep_tex = TRUE)
    expect_true(file.exists(file.path(dir, paste0(nm[1], ".tex"))))
    expect_true(file.exists(file.path(dir, paste0(nm[2], ".tex"))))
    unlink(dir, recursive = TRUE)
})
