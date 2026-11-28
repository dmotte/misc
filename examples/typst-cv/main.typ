#import "@preview/iconify:0.5.3": icon, provide-icons

#provide-icons(json("icons/mdi.json"))

#set document(
  // For English-language resumes, "Firstname Lastname" is the better choice
  title: [CV John Doe],
  author: "John Doe",
)

////////////////////////////////////////////////////////////////////////////////

#set page(numbering: "1 / 1", number-align: right)

#set text(
  font: "Liberation Sans",
  size: 10pt,
  ligatures: false, // To increase ATS compliance
)

#set par(justify: true)

#let accent = rgb("#05a")

#show title: set text(size: 1.1em, fill: accent)

#show heading.where(level: 1): it => block(breakable: false, sticky: true)[
  #set text(fill: accent)
  #it
  #v(-0.6em)
  #line(length: 100%, stroke: 1pt + accent)
  #v(1em)
]

#show heading.where(level: 2): set text(fill: accent)

#show link: it => {
  set text(fill: accent)
  underline(it)
}

#let link-clean(url) = link(
  url,
  url.replace(regex("^https?://(www\.)?"), "").trim("/", at: end),
)

#let ilicon = icon.with(width: 1.3em, y: -0.3em) // Inline icon
#let ilicon-accent(..args) = text(fill: accent)[#ilicon(..args)]

#let fmt-ym(year, month) = datetime(year: year, month: month, day: 1).display(
  "[month repr:short] [year]",
)

#let fmt-ymd(year, month, day) = datetime(
  year: year,
  month: month,
  day: day,
).display("[day padding:none] [month repr:short] [year]")

////////////////////////////////////////////////////////////////////////////////

#let entry-rich(icon-name, title, period, entity, description) = block(
  breakable: false,
)[
  #grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    align: (left, right),

    heading(level: 2, title),
    // The box(height: 0pt, ...) is needed to allow multiline periods to
    // overflow downward without increasing the grid height
    box(height: 0pt, text(fill: luma(50%), period)),
  )

  #if entity != [] [#ilicon-accent(icon-name) ~ #entity]

  #description

  #v(1em)
]

#let entry-mini(icon-name, description) = block(breakable: false)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 1em,

    ilicon-accent(icon-name), description,
  )

  #v(1em)
]

////////////////////////////////////////////////////////////////////////////////

#grid(
  columns: (1fr, auto),
  column-gutter: 1.5em,
  // Vertically center content
  align: horizon,
  [
    #title[John Doe]

    #v(0.5em)

    #text(size: 0.9em)[
      #stack(
        dir: ttb,
        spacing: 1.2em,
        [#ilicon-accent("mdi:card-account-details") ~ *Nationality*: American],
        [#ilicon-accent("mdi:calendar-month") ~ *Date of Birth*:
          #fmt-ymd(1970, 1, 1)],
        [#ilicon-accent("mdi:account") ~ *Gender*: Male],
        [#ilicon-accent("mdi:home") ~ *Address*: _City, Country_],
        [#ilicon-accent("mdi:phone") ~ *Phone*: #link(
            "tel:+15550100100",
          )[+1 555 010 0100]],
        [#ilicon-accent("mdi:email") ~ *E-mail*: #link(
            "mailto:john.doe@example.com",
          )[john.doe\@example.com]],
        [#ilicon-accent("mdi:earth") ~ *Website*: #link-clean(
            "https://example.com/",
          )],
      )
    ]
  ],
  // For the CV photo, top right is the most standard placement
  box(
    width: 3cm,
    height: 3cm,
    radius: 50%,
    clip: true,
    stroke: 1.5pt + accent,
    image(
      "img/propic.svg",
      width: 100%,
      height: 100%,
      fit: "cover",
    ),
  ),
)

#v(1em)

#block(breakable: false)[
  #lorem(50)
]

#v(0.5em)

= Work Experience

#let entry-work = entry-rich.with("mdi:domain")

#entry-work[Senior Project Manager][
  #fmt-ym(1970, 1) -- #fmt-ym(1970, 1)][
  *Acme Corporation* -- _City, Country_ -- #link-clean("https://example.com/")][

  - *First Item*: #lorem(20)
  - *Second Item*: #lorem(20)
  - *Third Item*: #lorem(20)
]

= Education and Training

#let entry-edu = entry-rich.with("mdi:school")

#entry-edu[Bachelor's Degree in Computer Science][
  #fmt-ym(1970, 1) -- #fmt-ym(1970, 1)][
  *State University* -- _City, Country_ -- #link-clean("https://example.com/")][

  - *Thesis*: _#lorem(10)_
  - *Final Grade*: 100/100
]

= Section with Bulleted List

#block(breakable: false)[
  - *First Item*: #lorem(20)
  - *Second Item*: #lorem(20)
  - *Third Item*: #lorem(20)
]

= Journal Publications

#let entry-pub = entry-mini.with("mdi:book")

#entry-pub[
  #lorem(5) -- _#lorem(15)_ -- #lorem(5)
]

= Languages

#block(breakable: false)[
  - *English*: Native
  - *Spanish*: Advanced (C1)

  #text(size: 0.8em, fill: luma(50%))[
    Levels: *A1/A2*: Basic user -- *B1/B2*: Independent user -- *C1/C2*:
    Proficient user \
    Common European Framework of Reference for Languages
  ]
]

= Driving Licenses

#block(breakable: false)[
  #ilicon-accent("mdi:moped") *Category AM* (EU)

  #ilicon-accent("mdi:car") *Category B* (EU)
]

= Privacy and Data Protection

#block(breakable: false)[
  I hereby authorize the use of my personal data in accordance to the *GDPR
  679/16* -- "_European regulation on the protection of personal data_".

  #v(1em)

  #text(size: 0.9em)[
    #datetime.today().display() #h(1fr) _John Doe_
  ]
]
