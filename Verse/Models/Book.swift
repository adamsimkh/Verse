import Foundation

/// Local fixtures for the exploration. These can later be supplied by a catalogue API
/// without changing any of the view contracts.
struct Book: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let author: String
    let progress: String?
    let coverAssetName: String?
    /// An ISBN lets the exploration display a real cover through Open Library’s Covers API.
    let coverISBN: String?
    /// Open Library cover identifier used when an ISBN is unavailable in live results.
    var coverOpenLibraryID: Int? = nil
    /// Subjects let Verse rank relevant recommendations from a user's reading activity.
    var genres: [String] = []
    let coverTitle: String
    let rating: Double
    let ratingCountText: String
    let summary: String
    let authorBio: String
    let reviews: [BookReview]

    var remoteCoverURL: URL? {
        // Medium covers are much lighter than the large originals while remaining sharp
        // at the size Verse displays them in its grids.
        if let coverISBN {
            return URL(string: "https://covers.openlibrary.org/b/isbn/\(coverISBN)-M.jpg?default=false")
        }

        if let coverOpenLibraryID {
            return URL(string: "https://covers.openlibrary.org/b/id/\(coverOpenLibraryID)-M.jpg?default=false")
        }

        return nil
    }
}

struct BookReview: Identifiable, Hashable, Codable {
    let id: String
    let reviewer: String
    let rating: Int
    let text: String
}

struct BookChapter: Identifiable, Hashable {
    let number: Int
    let subtitle: String
    let paragraphs: [String]

    var id: Int { number }
}

enum BookCatalog {
    static let continueReading = [dreamCount, atmosphere, martyr]
    static let trending = [
        days107, beautifulUgly, shadows, glassHarbour,
        nightBloom, lastLibrary, atlasOfSmallThings, velvetHours
    ]
    static let forYou = [
        fireWeather, northWoods, orchardMap, riverBetweenUs,
        quietEngine, houseOfTides, lightYearsApart, longReturn
    ]
    static let libraryStarterBooks = [fireWeather, northWoods, birnamWood, fourthWing]

    static let fireWeather = Book(
        id: "fire-weather",
        title: "Fire Weather",
        author: "John Vaillant",
        progress: "35%",
        coverAssetName: "FireWeatherCover",
        coverISBN: nil,
        coverTitle: "FIRE\nWEATHER",
        rating: 4.7,
        ratingCountText: "1.2k reviews",
        summary: "A gripping, deeply reported journey into the front lines of a burning world — revealing how wildfires are shaping our future.",
        authorBio: "John Vaillant is an award-winning journalist and bestselling author known for writing about nature, environment, and human resilience.",
        reviews: [
            review("fire-weather", "Olivia M.", 5, "An essential read. Beautifully written."),
            review("fire-weather", "Marcus T.", 4, "Strong reporting, slightly dense at times.")
        ]
    )

    static let dreamCount = Book(
        id: "dream-count",
        title: "Dream Count",
        author: "Chimamanda Ngozi Adichie",
        progress: "47%",
        coverAssetName: "DreamCountCover",
        coverISBN: nil,
        coverTitle: "DREAM COUNT",
        rating: 4.6,
        ratingCountText: "820 reviews",
        summary: "Four women, separated by continents and years of expectation, reconsider the stories they have told about love, belonging, and the lives they still want to live.",
        authorBio: "Chimamanda Ngozi Adichie is a novelist and essayist whose work explores identity, family, and the ties that span countries and generations.",
        reviews: [
            review("dream-count", "Nadia K.", 5, "Intimate, observant, and impossible to rush."),
            review("dream-count", "Ruth E.", 4, "A beautifully layered group of voices.")
        ]
    )

    static let atmosphere = Book(
        id: "atmosphere",
        title: "Atmosphere",
        author: "Taylor Jenkins Reid",
        progress: "56%",
        coverAssetName: "AtmosphereCover",
        coverISBN: nil,
        coverTitle: "ATMOSPHERE",
        rating: 4.5,
        ratingCountText: "960 reviews",
        summary: "At the edge of a new era in spaceflight, a brilliant crew discovers how fragile ambition becomes when it is tested by distance, risk, and love.",
        authorBio: "Taylor Jenkins Reid writes character-driven novels about ambition, connection, and the private cost of public dreams.",
        reviews: [
            review("atmosphere", "Mina S.", 5, "Big-hearted and wonderfully cinematic."),
            review("atmosphere", "Elliot P.", 4, "The crew dynamics kept me turning pages.")
        ]
    )

    static let martyr = Book(
        id: "martyr",
        title: "Martyr!",
        author: "Kaveh Akbar",
        progress: "82%",
        coverAssetName: nil,
        coverISBN: "9780593537619",
        coverTitle: "MARTYR!",
        rating: 4.4,
        ratingCountText: "740 reviews",
        summary: "A searching novel about grief, recovery, and the strange ways a person tries to make a life feel meaningful after loss.",
        authorBio: "Kaveh Akbar is a poet and novelist interested in faith, art, recovery, and the stories people inherit from their families.",
        reviews: [
            review("martyr", "Tom A.", 5, "Brave, funny, and deeply alive."),
            review("martyr", "Leila H.", 4, "A novel that rewards rereading.")
        ]
    )

    static let days107 = Book(
        id: "107-days",
        title: "107 Days",
        author: "Kamala Harris",
        progress: nil,
        coverAssetName: "Days107Cover",
        coverISBN: nil,
        coverTitle: "107 DAYS",
        rating: 4.2,
        ratingCountText: "510 reviews",
        summary: "A fast-moving political memoir about the compressed days when preparation, responsibility, and public life collide.",
        authorBio: "Kamala Harris is a public servant and former prosecutor whose career has included local, state, and national leadership.",
        reviews: [
            review("107-days", "Jamie L.", 4, "A clear view from inside a demanding moment."),
            review("107-days", "Kofi B.", 4, "Direct and energetic throughout.")
        ]
    )

    static let beautifulUgly = Book(
        id: "beautiful-ugly",
        title: "Beautiful Ugly",
        author: "Alice Feeney",
        progress: nil,
        coverAssetName: "BeautifulUglyCover",
        coverISBN: nil,
        coverTitle: "BEAUTIFUL UGLY",
        rating: 4.3,
        ratingCountText: "680 reviews",
        summary: "A tense psychological mystery in which an isolated setting, a missing truth, and an unreliable memory begin to close in on one another.",
        authorBio: "Alice Feeney writes twist-driven psychological fiction with sharp, emotionally complex narrators.",
        reviews: [
            review("beautiful-ugly", "Callie W.", 5, "I trusted no one by the final chapter."),
            review("beautiful-ugly", "Jay R.", 4, "Dark, clever, and seriously compulsive.")
        ]
    )

    static let shadows = Book(
        id: "shadows",
        title: "The God of the Woods",
        author: "Liz Moore",
        progress: nil,
        coverAssetName: nil,
        coverISBN: "9780593418918",
        coverTitle: "THE GOD\nOF THE\nWOODS",
        rating: 4.4,
        ratingCountText: "1.4k reviews",
        summary: "After a teenage camper disappears from an Adirondack summer camp, a search reveals the history, power, and buried grief surrounding the family who owns it.",
        authorBio: "Liz Moore is a novelist whose work explores class, family, place, and the secrets people keep from one another.",
        reviews: [
            review("shadows", "Sasha P.", 4, "Moody in the best possible way."),
            review("shadows", "Hannah V.", 4, "A slow burn with a satisfying final turn.")
        ]
    )

    static let northWoods = Book(
        id: "north-woods",
        title: "North Woods",
        author: "Daniel Mason",
        progress: "50%",
        coverAssetName: nil,
        coverISBN: "9780593534663",
        coverTitle: "NORTH\nWOODS",
        rating: 4.5,
        ratingCountText: "1.0k reviews",
        summary: "Across centuries, one house and the landscape around it hold the traces of the people who pass through — and the lives that echo after them.",
        authorBio: "Daniel Mason is a novelist whose work often connects history, landscape, and the long afterlife of human choices.",
        reviews: [
            review("north-woods", "Ari N.", 5, "A whole world contained in one place."),
            review("north-woods", "Grace Y.", 4, "Lyrical, strange, and wonderfully ambitious.")
        ]
    )

    static let birnamWood = Book(
        id: "birnam-wood",
        title: "Birnam Wood",
        author: "Eleanor Catton",
        progress: "90%",
        coverAssetName: nil,
        coverISBN: "9780374110335",
        coverTitle: "BIRNAM\nWOOD",
        rating: 4.4,
        ratingCountText: "890 reviews",
        summary: "A guerrilla gardening collective and a remote land deal become entangled in a darkly comic, high-stakes contest over power and survival.",
        authorBio: "Eleanor Catton is a novelist and screenwriter known for intricate stories about power, consequence, and moral compromise.",
        reviews: [
            review("birnam-wood", "Milo D.", 5, "Sharp, unsettling, and wildly entertaining."),
            review("birnam-wood", "Iris C.", 4, "The tension builds with extraordinary control.")
        ]
    )

    static let fourthWing = Book(
        id: "fourth-wing",
        title: "Fourth Wing",
        author: "Rebecca Yarros",
        progress: "24%",
        coverAssetName: nil,
        coverISBN: "9781649374042",
        coverTitle: "FOURTH\nWING",
        rating: 4.6,
        ratingCountText: "2.4k reviews",
        summary: "At an elite war college where dragons choose their riders, a determined cadet must survive training, rivalry, and a secret that could change everything.",
        authorBio: "Rebecca Yarros writes emotional, high-stakes fiction about courage, loyalty, and the people who challenge us to become more.",
        reviews: [
            review("fourth-wing", "Zoe R.", 5, "Fast, fierce, and so much fun."),
            review("fourth-wing", "Priya G.", 4, "The perfect book to get lost in for a weekend.")
        ]
    )

    static let orchardMap = catalogBook(
        id: "orchard-map",
        title: "The Heaven & Earth Grocery Store",
        author: "James McBride",
        coverISBN: "9780593743775",
        coverTitle: "THE HEAVEN &\nEARTH\nGROCERY STORE",
        rating: 4.5,
        ratingCount: "1.1k reviews",
        summary: "A long-hidden secret in a Pennsylvania neighbourhood brings together the intertwined stories of its Black and Jewish residents.",
        authorFocus: "McBride is an award-winning novelist and musician whose fiction often centres community, history, and moral imagination."
    )

    static let glassHarbour = catalogBook(
        id: "glass-harbour",
        title: "Demon Copperhead",
        author: "Barbara Kingsolver",
        coverISBN: "9780063251922",
        coverTitle: "DEMON\nCOPPERHEAD",
        rating: 4.3,
        ratingCount: "740 reviews",
        summary: "A fiercely funny coming-of-age novel follows a boy growing up in the mountains of southern Appalachia.",
        authorFocus: "Kingsolver is a Pulitzer Prize–winning novelist whose work connects character, ecology, and social justice."
    )

    static let atlasOfSmallThings = catalogBook(
        id: "atlas-small-things",
        title: "The Ministry of Time",
        author: "Kaliane Bradley",
        coverISBN: "9781399726344",
        coverTitle: "THE MINISTRY\nOF TIME",
        rating: 4.6,
        ratingCount: "1.5k reviews",
        summary: "A civil servant is assigned to live with a nineteenth-century explorer brought to the present by a government time-travel experiment.",
        authorFocus: "Bradley writes inventive fiction about history, power, and the strange intimacy of living across time."
    )

    static let nightBloom = catalogBook(
        id: "night-bloom",
        title: "James",
        author: "Percival Everett",
        coverISBN: "9780385550369",
        coverTitle: "JAMES",
        rating: 4.4,
        ratingCount: "680 reviews",
        summary: "A bold reimagining of Adventures of Huckleberry Finn told from the perspective of Jim as he pursues freedom.",
        authorFocus: "Everett is an acclaimed novelist whose work moves fluently between satire, philosophy, and American history."
    )

    static let lastLibrary = catalogBook(
        id: "last-library",
        title: "The Women",
        author: "Kristin Hannah",
        coverISBN: "9781250178657",
        coverTitle: "THE\nWOMEN",
        rating: 4.7,
        ratingCount: "2.3k reviews",
        summary: "A young woman joins the Army Nurse Corps during the Vietnam War and discovers the enduring cost of courage, friendship, and coming home.",
        authorFocus: "Hannah is a bestselling novelist known for emotionally immersive historical fiction."
    )

    static let velvetHours = catalogBook(
        id: "velvet-hours",
        title: "The Wedding People",
        author: "Alison Espach",
        coverISBN: "9781250899576",
        coverTitle: "THE\nWEDDING\nPEOPLE",
        rating: 4.2,
        ratingCount: "590 reviews",
        summary: "A woman who arrives at a Rhode Island hotel at a breaking point becomes unexpectedly entangled in a wedding weekend.",
        authorFocus: "Espach writes smart, emotionally candid novels about connection and reinvention."
    )

    static let riverBetweenUs = catalogBook(
        id: "river-between-us",
        title: "Intermezzo",
        author: "Sally Rooney",
        coverISBN: "9780374602635",
        coverTitle: "INTERMEZZO",
        rating: 4.5,
        ratingCount: "970 reviews",
        summary: "Two brothers reckon with grief, intimacy, and the different lives they have built after their father’s death.",
        authorFocus: "Rooney writes intimate contemporary fiction about love, work, family, and class."
    )

    static let quietEngine = catalogBook(
        id: "quiet-engine",
        title: "The Familiar",
        author: "Leigh Bardugo",
        coverISBN: "9781250884251",
        coverTitle: "THE\nFAMILIAR",
        rating: 4.1,
        ratingCount: "440 reviews",
        summary: "In the Spanish Golden Age, a woman with a gift for small miracles must decide whom she can trust with her secret.",
        authorFocus: "Bardugo writes richly imagined fantasy with an eye for history, power, and peril."
    )

    static let houseOfTides = catalogBook(
        id: "house-of-tides",
        title: "The Safekeep",
        author: "Yael van der Wouden",
        coverISBN: "9781668034342",
        coverTitle: "THE\nSAFEKEEP",
        rating: 4.4,
        ratingCount: "860 reviews",
        summary: "In the aftermath of war, a young Dutch woman’s careful life is unsettled by the arrival of a stranger carrying a secret.",
        authorFocus: "Van der Wouden writes psychologically charged historical fiction about memory, desire, and possession."
    )

    static let lightYearsApart = catalogBook(
        id: "light-years-apart",
        title: "All Fours",
        author: "Miranda July",
        coverISBN: "9780593190265",
        coverTitle: "ALL\nFOURS",
        rating: 4.6,
        ratingCount: "1.8k reviews",
        summary: "A woman on the verge of a cross-country reinvention makes an impulsive detour that changes her life and marriage.",
        authorFocus: "July is an artist and novelist whose work is playful, intimate, and formally adventurous."
    )

    static let longReturn = catalogBook(
        id: "long-return",
        title: "Long Island",
        author: "Colm Tóibín",
        coverISBN: "9781476785118",
        coverTitle: "LONG\nISLAND",
        rating: 4.3,
        ratingCount: "710 reviews",
        summary: "Eilis Lacey returns to Ireland and must confront a life-changing secret decades after leaving home for Brooklyn.",
        authorFocus: "Tóibín is an award-winning novelist known for elegant, emotionally precise portraits of family and exile."
    )

    static let fieldNotesForFire = catalogBook(
        id: "field-notes-fire",
        title: "The Heart’s Invisible Furies",
        author: "John Boyne",
        coverISBN: "9781524760793",
        coverTitle: "THE HEART’S\nINVISIBLE\nFURIES",
        rating: 4.5,
        ratingCount: "920 reviews",
        summary: "A sweeping life story follows Cyril Avery from his unconventional childhood in Dublin into a long search for belonging.",
        authorFocus: "Boyne writes bestselling historical and literary fiction with a strong sense of character and place."
    )

    static let cartographersRoom = catalogBook(
        id: "cartographers-room",
        title: "The Song of Achilles",
        author: "Madeline Miller",
        coverISBN: "9780062060624",
        coverTitle: "THE SONG\nOF ACHILLES",
        rating: 4.2,
        ratingCount: "630 reviews",
        summary: "A lyrical retelling of the Trojan War centres the bond between Patroclus and Achilles.",
        authorFocus: "Miller writes mythic fiction that brings classical worlds to vivid emotional life."
    )

    static let ordinaryGravity = catalogBook(
        id: "ordinary-gravity",
        title: "Tomorrow, and Tomorrow, and Tomorrow",
        author: "Gabrielle Zevin",
        coverISBN: "9780593321201",
        coverTitle: "TOMORROW,\nAND TOMORROW,\nAND TOMORROW",
        rating: 4.4,
        ratingCount: "780 reviews",
        summary: "Two friends become creative partners in the world of video games, testing what collaboration, ambition, and love can survive.",
        authorFocus: "Zevin writes inventive novels about creativity, friendship, and the stories people make together."
    )

    static let boneAndSalt = catalogBook(
        id: "bone-and-salt",
        title: "Yellowface",
        author: "R. F. Kuang",
        coverISBN: "9780063250833",
        coverTitle: "YELLOWFACE",
        rating: 4.1,
        ratingCount: "510 reviews",
        summary: "A darkly comic novel about authorship, cultural appropriation, and what ambition can make a writer willing to claim.",
        authorFocus: "Kuang writes acclaimed fiction that interrogates power, history, and the stories institutions reward."
    )

    static let pilgrimsLantern = catalogBook(
        id: "pilgrims-lantern",
        title: "Babel",
        author: "R. F. Kuang",
        coverISBN: "9780063021428",
        coverTitle: "BABEL",
        rating: 4.6,
        ratingCount: "1.2k reviews",
        summary: "At Oxford’s Royal Institute of Translation, a young scholar discovers how language, empire, and magic are bound together.",
        authorFocus: "Kuang is a novelist whose work blends speculative imagination with sharp historical and social critique."
    )

    static let beforeTheWeather = catalogBook(
        id: "before-the-weather",
        title: "The Midnight Library",
        author: "Matt Haig",
        coverISBN: "9780525559498",
        coverTitle: "THE\nMIDNIGHT\nLIBRARY",
        rating: 4.3,
        ratingCount: "650 reviews",
        summary: "Between life and death, a woman discovers a library that lets her explore the paths her life might have taken.",
        authorFocus: "Haig writes accessible, imaginative fiction about hope, possibility, and the lives people choose."
    )

    static let paperMoons = catalogBook(
        id: "paper-moons",
        title: "The Seven Moons of Maali Almeida",
        author: "Shehan Karunatilaka",
        coverISBN: "9781324091730",
        coverTitle: "THE SEVEN\nMOONS OF\nMAALI ALMEIDA",
        rating: 4.5,
        ratingCount: "1.0k reviews",
        summary: "A war photographer wakes in the afterlife and has seven moons to learn who killed him and protect those he left behind.",
        authorFocus: "Karunatilaka is a Sri Lankan novelist whose fiction blends political urgency, dark humour, and the supernatural."
    )

    static func book(withID id: Book.ID) -> Book? {
        allBooks.first { $0.id == id }
    }

    static func books(withIDs ids: Set<Book.ID>) -> [Book] {
        allBooks.filter { ids.contains($0.id) }
    }

    static func genres(for book: Book) -> [String] {
        if !book.genres.isEmpty {
            return book.genres
        }

        switch book.id {
        case "fire-weather", "field-notes-for-fire", "before-the-weather":
            return ["nature", "science", "history"]
        case "dream-count", "atmosphere", "beautiful-ugly", "river-between-us", "light-years-apart":
            return ["literary fiction", "romance", "contemporary"]
        case "martyr", "paper-moons", "pilgrims-lantern", "velvet-hours":
            return ["literary fiction", "historical fiction"]
        case "north-woods", "birnam-wood", "orchard-map", "house-of-tides":
            return ["literary fiction", "nature"]
        case "fourth-wing", "night-bloom", "bone-and-salt", "cartographers-room":
            return ["fantasy", "romance", "adventure"]
        case "107-days", "ordinary-gravity":
            return ["biography", "history", "politics"]
        case "shadows", "glass-harbour", "quiet-engine", "last-library":
            return ["mystery", "thriller"]
        default:
            return ["fiction"]
        }
    }

    static let allBooks = [
        fireWeather, dreamCount, atmosphere, martyr, days107, beautifulUgly,
        shadows, northWoods, birnamWood, fourthWing, orchardMap, glassHarbour,
        atlasOfSmallThings, nightBloom, quietEngine, lastLibrary, velvetHours,
        riverBetweenUs, houseOfTides, lightYearsApart, longReturn, fieldNotesForFire,
        cartographersRoom, ordinaryGravity, boneAndSalt, pilgrimsLantern,
        beforeTheWeather, paperMoons
    ]

    private static func catalogBook(
        id: String,
        title: String,
        author: String,
        coverISBN: String,
        coverTitle: String,
        rating: Double,
        ratingCount: String,
        summary: String,
        authorFocus: String
    ) -> Book {
        Book(
            id: id,
            title: title,
            author: author,
            progress: nil,
            coverAssetName: nil,
            coverISBN: coverISBN,
            coverTitle: coverTitle,
            rating: rating,
            ratingCountText: ratingCount,
            summary: summary,
            authorBio: "\(author) is a novelist known for immersive storytelling. \(authorFocus)",
            reviews: [
                review(id, "Nia R.", 5, "Vivid, assured, and difficult to put down."),
                review(id, "Owen P.", 4, "A beautifully realised world with plenty to think about.")
            ]
        )
    }

    private static func review(_ bookID: String, _ reviewer: String, _ rating: Int, _ text: String) -> BookReview {
        BookReview(
            id: "\(bookID)-\(reviewer.lowercased().replacingOccurrences(of: " ", with: "-"))",
            reviewer: reviewer,
            rating: rating,
            text: text
        )
    }
}

enum BookReaderCatalog {
    static func chapters(for book: Book) -> [BookChapter] {
        let content = chapterContent[book.id]
        let baseTitles = content?.titles ?? generatedBaseTitles
        let basePassages = content?.passages ?? baseTitles.enumerated().map { index, title in
            generatedOpening(for: book, title: title, chapterNumber: index + 1)
        }
        let extraTitles = additionalChapterTitles[book.id]
            ?? generatedAdditionalTitles(for: book, after: baseTitles.count)
        let titles = baseTitles + extraTitles
        let passages = basePassages + extraTitles.enumerated().map { index, title in
            generatedOpening(for: book, title: title, chapterNumber: baseTitles.count + index + 1)
        }

        return zip(titles.indices, titles).map { index, title in
            BookChapter(
                number: index + 1,
                subtitle: title,
                paragraphs: longFormParagraphs(
                    for: book,
                    chapterNumber: index + 1,
                    opening: passages[index]
                )
            )
        }
    }

    private struct ChapterContent {
        let titles: [String]
        let passages: [String]
    }

    private static let additionalChapterTitles: [Book.ID: [String]] = [
        "fire-weather": [
            "Ashfall", "The Red Sky", "A Line of Water", "After the Sirens", "What Remains", "First Rain"
        ],
        "dream-count": [
            "The Blue Hour", "A Different Country", "The Shape of Returning"
        ],
        "atmosphere": [
            "The Quiet Between", "Signal Delay"
        ],
        "martyr": [
            "A Small Light"
        ],
        "107-days": [
            "The Last Call", "A Door Opens"
        ],
        "beautiful-ugly": [
            "The Empty Room"
        ],
        "shadows": [
            "The Names We Keep", "Morning Tide"
        ],
        "north-woods": [
            "The Orchard", "A Century of Snow", "The Door in Spring", "The Last Clearing"
        ],
        "birnam-wood": [
            "The Hidden Gate", "Fault Lines", "No Safe Ground", "A Different Season"
        ],
        "fourth-wing": [
            "The Gauntlet", "Stormbound", "A Rider's Oath", "The Burning Archive", "The Choice", "Dawn Over Basgiath"
        ]
    ]

    private static let generatedBaseTitles = [
        "The Arrival", "A Familiar Silence", "The Turning Point", "Open Water"
    ]

    private static let generatedTitlePool = [
        "The Unmarked Road", "A Light in the Window", "What the Map Kept",
        "The Second Morning", "All the Way Home", "A Different Weather"
    ]

    private static let targetChapterCounts: [Book.ID: Int] = [
        "last-library": 10,
        "cartographers-room": 10,
        "paper-moons": 10,
        "house-of-tides": 8,
        "field-notes-fire": 8,
        "bone-and-salt": 8,
        "quiet-engine": 7,
        "light-years-apart": 7
    ]

    private static let longFormContinuations = [
        "The details arrived one at a time: a changed light, an unanswered question, a sound that made everyone pause. None of them seemed decisive alone, but together they altered the shape of the day.",
        "No one said exactly what they feared. The silence around the subject grew careful instead, and every ordinary task began to feel like a way of measuring the distance to a decision.",
        "Outside, the world continued with an almost unreasonable calm. Traffic passed, doors opened and closed, and somewhere a radio played a song that belonged to a much easier afternoon.",
        "They made a plan because making a plan was what people did when certainty was unavailable. It was imperfect, full of blank spaces, but it gave the next hour an edge to hold on to.",
        "Memory kept offering small corrections: a look that had lasted too long, a phrase that had sounded harmless at the time, a route that now seemed to lead somewhere else entirely.",
        "The conversation moved slowly, then all at once. By the end of it, each person had understood something different, and that difference became its own kind of responsibility.",
        "Later, when the pressure had eased, the smallest kindnesses were the ones that stayed visible. A cup set down without being asked for. A message answered before it became urgent. A hand held steady.",
        "There was work to do, but no clean way through it. The only honest choice was to keep going carefully, noticing what could be saved and what had already changed beyond repair.",
        "At the edge of evening, the air seemed to hold its breath. The horizon gathered colour slowly, giving everyone one last chance to say what they meant.",
        "What happened next did not arrive as a revelation. It came through repetition: one step, then another; one question, then a better question; one small act of courage after the next.",
        "For a moment, the future felt close enough to touch. Then it shifted again, asking not for certainty but for attention, patience, and the willingness to begin where they were.",
        "By night, the scene had become a story each person would tell differently. Still, beneath the changing details, they shared the same knowledge: nothing important would be solved by looking away."
    ]

    private static func generatedOpening(for book: Book, title: String, chapterNumber: Int) -> String {
        "In chapter \(chapterNumber), \(title.lowercased()) arrived without ceremony. For \(book.title), it was the kind of moment that looked ordinary until someone noticed how completely the room had changed."
    }

    private static func generatedAdditionalTitles(for book: Book, after baseChapterCount: Int) -> [String] {
        let targetCount = targetChapterCounts[book.id] ?? 6
        let neededCount = max(targetCount - baseChapterCount, 0)
        return Array(generatedTitlePool.prefix(neededCount))
    }

    private static func longFormParagraphs(
        for book: Book,
        chapterNumber: Int,
        opening: String
    ) -> [String] {
        let startingIndex = (book.id.unicodeScalars.reduce(0) { $0 + Int($1.value) } + chapterNumber) % longFormContinuations.count
        let continuationParagraphs = (0..<longFormContinuations.count).map { offset in
            let paragraph = longFormContinuations[(startingIndex + offset) % longFormContinuations.count]
            return "\(paragraph) In \(book.title), chapter \(chapterNumber) carried that feeling forward."
        }

        let bookSpecificParagraph = "At the heart of \(book.title) is a question that keeps returning: \(book.summary)"
        return [opening, bookSpecificParagraph] + continuationParagraphs
    }

    private static let chapterContent: [Book.ID: ChapterContent] = [
        "fire-weather": ChapterContent(
            titles: ["The Long Summer", "Signals in the Smoke", "Into the Emberlands", "When the Wind Turns"],
            passages: [
                "By noon, the heat had settled over the valley like a second roof. Every window stood open, but the air inside the houses did not move.",
                "The first plume appeared just after breakfast, thin enough to mistake for cloud. It rose behind the western hills and flattened in the high air.",
                "A dry wind pushed through the valley, carrying the faint smell of smoke. John paused, listening to a distant crackle rise like a warning.",
                "At first, the change was almost impossible to notice. A cool thread moved through the smoke, then another, and the trees began to whisper east."
            ]
        ),
        "dream-count": ChapterContent(
            titles: ["The Unsent Letter", "A Map of Elsewhere", "Names for the Future", "The Room With No View"],
            passages: [
                "Chiamaka kept the letter folded inside a cookbook, between the pages that still smelled faintly of cardamom. She had written it years ago and never once addressed the envelope.",
                "Across the city, Zikora traced an old route on her phone, following streets she had once known by heart. Every turn offered a version of the life she had not chosen.",
                "On a long-distance call, a question landed softly and changed the whole evening: what do we call a future when we are afraid to want it?",
                "The hotel room faced a brick wall, but at dawn the reflected light made it seem briefly open. For a minute, no one had to decide what came next."
            ]
        ),
        "atmosphere": ChapterContent(
            titles: ["Launch Window", "Weightless", "Night Side", "Return Trajectory"],
            passages: [
                "The countdown was already in motion when Joan noticed the small crack in the observation glass. It was harmless, she told herself, but it changed the shape of every number that followed.",
                "In orbit, the smallest objects became strange: a pencil, a loose curl of hair, a photograph that would not stay flat against the wall.",
                "On the night side of Earth, the crew spoke more quietly. Below them, cities lit the dark with their patient constellations.",
                "The return path had been calculated a hundred times. What no one could calculate was how it would feel to carry home the things they had learned to leave behind."
            ]
        ),
        "martyr": ChapterContent(
            titles: ["The Museum", "A Body of Water", "Small Mercies", "The Bright Room"],
            passages: [
                "Cyrus went to the museum because the rooms were free and the air was cool. By the time he reached the final gallery, he had begun to believe the paintings were looking back.",
                "At the river, he watched a plastic bag catch on a branch and swell with water. It seemed both ridiculous and important, like a message from a life he had misplaced.",
                "The kindness arrived without ceremony: a stranger holding a door, a friend leaving soup on the step, a voice on the phone that did not demand an explanation.",
                "In the bright room, he understood that survival was not a single dramatic decision. It was an accumulation of ordinary mornings."
            ]
        ),
        "107-days": ChapterContent(
            titles: ["The Briefing", "The Calendar", "A Long Night", "Day One Hundred Seven"],
            passages: [
                "The briefing book was heavier than it looked. Inside were timelines, contingencies, names, and the blank space where certainty should have been.",
                "Every square on the calendar filled before breakfast. The real work happened in the margins, in conversations that continued after the cameras had gone.",
                "Near midnight, the office windows reflected a room still awake. Outside, the city seemed to be holding its breath with them.",
                "By the final morning, the pace had become its own kind of language. Everyone knew what a raised eyebrow, a closed folder, or a pause in the hallway could mean."
            ]
        ),
        "beautiful-ugly": ChapterContent(
            titles: ["The House on the Cliff", "What She Remembered", "A Second Key", "Low Tide"],
            passages: [
                "The house had been waiting above the cliffs, all dark windows and weathered wood. It looked less abandoned than patient.",
                "Memory was not a film that could be replayed. It was a room someone had rearranged while she slept.",
                "The second key did not fit the front door. It opened a drawer beneath the stairs, where a photograph lay face down in a spill of sand.",
                "At low tide, the rocks exposed a narrow path along the shore. She followed it because staying inside had become more frightening."
            ]
        ),
        "shadows": ChapterContent(
            titles: ["The Archive", "Salt Air", "Exposure", "The Last Negative"],
            passages: [
                "The archive smelled of dust, metal, and rain-soaked paper. In the back cabinet, someone had filed a photograph under a name that did not exist.",
                "By afternoon, salt had settled on the windows in a fine white skin. The sea was close enough to hear but too far to see.",
                "The image emerged slowly in the developer tray: a crowd on the pier, a dark sleeve at the edge of the frame, and a face turned away from the lens.",
                "The final negative held almost nothing at first glance. When he tilted it toward the lamp, the absence became a shape."
            ]
        ),
        "north-woods": ChapterContent(
            titles: ["The Clearing", "The House Remembers", "Mushroom Season", "A New Root"],
            passages: [
                "The clearing was smaller than it had been in the stories, but the trees around it carried their age without apology.",
                "In the old house, every floorboard seemed to hold an opinion. The building answered the wind in a language of creaks and settling beams.",
                "After rain, the forest floor changed overnight. Small bright caps appeared beneath the ferns, as if the earth had decided to speak in colour.",
                "At the edge of the garden, a new root had lifted the stones. No one had planted it there, but it had found its way toward the light."
            ]
        ),
        "birnam-wood": ChapterContent(
            titles: ["The Plot", "A Fence Line", "Terms of Use", "The Weather Closes In"],
            passages: [
                "Mira found the plot through an old satellite map and a tip from someone who had heard the owners were away. The soil looked difficult, which made it perfect.",
                "The fence line ran farther than anyone expected. On the other side, the grass was shorter, the cameras newer, and the silence more expensive.",
                "The agreement arrived in careful language, each clause polished until it almost stopped meaning anything. Mira read it twice and trusted it less each time.",
                "When the weather turned, the garden volunteers scattered home. The land stayed where it was, carrying every promise they had made on it."
            ]
        ),
        "fourth-wing": ChapterContent(
            titles: ["The Parapet", "A Dragon's Shadow", "The First Flight", "The Wing"],
            passages: [
                "The parapet was narrower than it looked from below. Violet kept her eyes forward and counted each step like a private spell.",
                "A shadow crossed the training yard, vast enough to silence the cadets. No one moved until the dragon chose where to land.",
                "The first flight stole the air from her lungs and returned it changed. Below, the world became a map with no safe route drawn on it.",
                "By nightfall, the wing had learned who would lead, who would challenge, and who had already begun to keep secrets."
            ]
        )
    ]
}
