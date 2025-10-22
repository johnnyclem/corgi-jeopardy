import Foundation

/// Generates Jeopardy style boards with a mix of general trivia and corgi or
/// dog themed categories.  The generator owns the data set so that both the
/// production game and tests can request deterministic boards by supplying a
/// custom random number generator.
struct BoardGenerator {
    private struct CategoryDefinition {
        let title: String
        let isDogCategory: Bool
        let clues: [(question: String, answer: String)]
    }

    private static let generalCategories: [CategoryDefinition] = {
        generalClueBank.map { title, clues in
            CategoryDefinition(title: title, isDogCategory: false, clues: clues)
        }
    }()

    private static let dogCategories: [CategoryDefinition] = {
        dogClueBank.map { title, clues in
            CategoryDefinition(title: title, isDogCategory: true, clues: clues)
        }
    }()

    private static let generalClueBank: [String: [(String, String)]] = [
        "History Highlights": [
            ("This ancient wonder of the world was built for Pharaoh Khufu.", "What is the Great Pyramid of Giza?"),
            ("He famously crossed the Rubicon in 49 BCE.", "Who is Julius Caesar?"),
            ("This U.S. document begins with the words 'We the People'.", "What is the Constitution?"),
            ("This war ended with the Treaty of Versailles in 1919.", "What is World War I?"),
            ("She was the queen who led England during the Spanish Armada in 1588.", "Who is Elizabeth I?"),
            ("This 19th-century U.S. purchase doubled the nation's size overnight.", "What is the Louisiana Purchase?"),
            ("This explorer completed the first circumnavigation of the globe, though he died en route.", "Who is Ferdinand Magellan?"),
            ("This 1989 event led to German reunification the following year.", "What is the fall of the Berlin Wall?"),
            ("This ancient city-state is known as the birthplace of democracy.", "What is Athens?"),
            ("This leader's 'Long March' became a symbol of Chinese Communist resilience.", "Who is Mao Zedong?")
        ],
        "Science Stuff": [
            ("This force keeps planets in orbit around the sun.", "What is gravity?"),
            ("He developed the theory of general relativity.", "Who is Albert Einstein?"),
            ("This table organizes chemical elements by atomic number.", "What is the periodic table?"),
            ("This gas makes up roughly 78% of Earth's atmosphere.", "What is nitrogen?"),
            ("This branch of biology studies heredity and genes.", "What is genetics?"),
            ("This scientist is known for the laws of planetary motion.", "Who is Johannes Kepler?"),
            ("This organelle is often called the powerhouse of the cell.", "What is the mitochondrion?"),
            ("This scale measures the magnitude of earthquakes.", "What is the Richter scale?"),
            ("This color of light has the shortest wavelength in the visible spectrum.", "What is violet?"),
            ("This particle has a positive charge and resides in the nucleus.", "What is the proton?")
        ],
        "Global Geography": [
            ("This river is the longest in South America.", "What is the Amazon River?"),
            ("This desert covers much of northern Africa.", "What is the Sahara?"),
            ("This city is the capital of Japan.", "What is Tokyo?"),
            ("This mountain range contains Mount Everest.", "What are the Himalayas?"),
            ("This African lake is the source of the White Nile.", "What is Lake Victoria?"),
            ("This European peninsula includes Spain and Portugal.", "What is the Iberian Peninsula?"),
            ("This island nation has Wellington as its capital.", "What is New Zealand?"),
            ("This canal links the Mediterranean Sea with the Red Sea.", "What is the Suez Canal?"),
            ("This Canadian province is the only officially bilingual one.", "What is New Brunswick?"),
            ("This Asian country is home to the ancient city of Petra.", "What is Jordan?")
        ],
        "Literary Legends": [
            ("He wrote '1984' and introduced Big Brother.", "Who is George Orwell?"),
            ("This bard penned 'Romeo and Juliet'.", "Who is William Shakespeare?"),
            ("This epic poem recounts the wrath of Achilles.", "What is 'The Iliad'?"),
            ("She created the wizarding world of Hogwarts.", "Who is J.K. Rowling?"),
            ("This American novelist wrote 'The Great Gatsby'.", "Who is F. Scott Fitzgerald?"),
            ("This Russian author gave us 'War and Peace'.", "Who is Leo Tolstoy?"),
            ("This novel features the character Holden Caulfield.", "What is 'The Catcher in the Rye'?"),
            ("This poet's 'Raven' once quoth 'Nevermore'.", "Who is Edgar Allan Poe?"),
            ("This dystopian classic was written by Aldous Huxley.", "What is 'Brave New World'?"),
            ("This author introduced us to Middle-earth in 'The Hobbit'.", "Who is J.R.R. Tolkien?")
        ],
        "Pop Culture Parade": [
            ("This cinematic universe features Iron Man and Thor.", "What is the Marvel Cinematic Universe?"),
            ("This singer is known as the 'Queen Bey'.", "Who is Beyoncé?"),
            ("This streaming service popularized 'Stranger Things'.", "What is Netflix?"),
            ("This long-running sketch show airs live from New York on Saturday nights.", "What is 'Saturday Night Live'?"),
            ("This video-sharing app is home to viral dance challenges.", "What is TikTok?"),
            ("This film franchise is set 'a long time ago in a galaxy far, far away'.", "What is Star Wars?"),
            ("This award show hands out golden gramophones.", "What are the Grammys?"),
            ("This British spy has been played by actors like Sean Connery and Daniel Craig.", "Who is James Bond?"),
            ("This sitcom follows the lives of six friends in New York City.", "What is 'Friends'?"),
            ("This video game features the Battle Royale island of Apollo.", "What is Fortnite?")
        ],
        "Tech Triumphs": [
            ("This company created the iPhone in 2007.", "What is Apple?"),
            ("This programming language shares its name with a reptile.", "What is Python?"),
            ("This law states that computing power doubles roughly every two years.", "What is Moore's Law?"),
            ("This device converts digital data into sound for playback.", "What is a speaker?"),
            ("This term describes malicious software designed to harm systems.", "What is malware?"),
            ("This early computer was famously built at Harvard with the help of Grace Hopper.", "What is the Mark I?"),
            ("This protocol secures web traffic with encryption.", "What is HTTPS?"),
            ("This technology powers digital currencies like Bitcoin.", "What is blockchain?"),
            ("This company popularized the search engine with PageRank.", "What is Google?"),
            ("This wearable device counts your steps and monitors your heart rate.", "What is a fitness tracker?")
        ]
    ]

    private static let dogClueBank: [String: [(String, String)]] = [
        "Corgi Facts": [
            ("This royal family famously adores corgis.", "Who are the British royals?"),
            ("This characteristic corgi feature looks like they're wearing fluffy pants.", "What are their britches?"),
            ("Pembrokes are born without these long appendages many dogs wag.", "What are long tails?"),
            ("This herding instinct means corgis may nip gently at heels.", "What is their cattle-driving heritage?"),
            ("This corgi nickname references their short stature.", "What is a low rider?"),
            ("This corgi coat color mixes red with a black saddle pattern.", "What is sable?"),
            ("This corgi variety hails from a Welsh county known for slate.", "What is the Cardigan?"),
            ("This canine job inspired the name 'corgi', meaning 'dwarf dog'.", "What is herding?"),
            ("This corgi feature requires regular brushing to reduce fluff storms.", "What is their double coat?"),
            ("This corgi vocalization sounds off when the doorbell rings.", "What is a bark?")
        ],
        "Paw-some Puns": [
            ("This corgi activity involves chasing tails.", "What is spinning?"),
            ("This snack break is when a corgi grabs a 'pup' of coffee.", "What is a bark-ista break?"),
            ("When a corgi tells a joke, it's known as stand-up on this four-legged stage.", "What is the pup crawl?"),
            ("This corgi musician's favorite instrument is the sub-woofer.", "What is a bassinet bone?"),
            ("A corgi's favorite workout is this stretch that ends with a downward doge.", "What is paws-lates?"),
            ("This corgi magician performs a paw-sitive disappearing trick.", "What is the abraca-bark-ra?"),
            ("This corgi's autobiography is titled 'Tail of Two Citties'.", "What is a bark-classic?"),
            ("This corgi philosopher muses, therefore he woofs this famous line.", "What is 'I think, therefore I wag'?"),
            ("When a corgi bakes bread, it's known as this knead-y hobby.", "What is loafing around?"),
            ("This corgi comedian brings down the house with paws-itive vibes.", "What is a stand-up pup?")
        ],
        "Dog Jobs": [
            ("This canine career involves guiding people with limited sight.", "What is a guide dog?"),
            ("These dogs sniff out missing people for rescue teams.", "What are search-and-rescue dogs?"),
            ("These uniformed pups enforce the law alongside officers.", "What are K-9 police dogs?"),
            ("These avalanche-savvy pups dig through snow to find skiers.", "What are mountain rescue dogs?"),
            ("These pups detect peanuts or pollen for allergic humans.", "What are medical alert dogs?"),
            ("These dogs pull sleds across snowy landscapes.", "What are sled dogs?"),
            ("These dogs visit hospitals to comfort patients.", "What are therapy dogs?"),
            ("These canines track illegal fruit entering airports.", "What are customs dogs?"),
            ("These farm dogs keep flocks of sheep in line.", "What are herding dogs?"),
            ("These pups sniff out bedbugs in hotels.", "What are pest detection dogs?")
        ],
        "Training Treats": [
            ("This command asks a dog to place its rump on the ground.", "What is 'sit'?"),
            ("This treat-based training method reinforces desired behaviors.", "What is positive reinforcement?"),
            ("This brief learning session keeps pups engaged without overload.", "What is a short training interval?"),
            ("This clicky device helps mark the exact moment a dog does something right.", "What is a clicker?"),
            ("This corgi reward includes belly rubs and praise galore.", "What is affection?"),
            ("This cue tells a pup to walk calmly beside you.", "What is 'heel'?"),
            ("This socialization period happens before 16 weeks of age.", "What is the critical puppy window?"),
            ("This type of treat should be pea-sized to avoid overfeeding.", "What is a high-value nibble?"),
            ("This command invites a dog to come sprinting your way.", "What is 'recall' or 'come'?"),
            ("This release word lets a dog know training time is done.", "What is 'free'?" )
        ]
    ]

    static func generateBoard<T: RandomNumberGenerator>(for round: GameState.Round, categoryCount: Int = 6, using rng: inout T) -> [GameState.Category] {
        guard categoryCount > 0 else { return [] }

        let dogCategoryCount = min(max(Int.random(in: 1...3, using: &rng), 1), categoryCount)
        let generalCount = max(categoryCount - dogCategoryCount, 0)

        let selectedDog = Array(dogCategories.shuffled(using: &rng).prefix(dogCategoryCount))
        let selectedGeneral = Array(generalCategories.shuffled(using: &rng).prefix(generalCount))
        var selected = selectedDog + selectedGeneral
        selected.shuffle(using: &rng)

        let baseValues = [200, 400, 600, 800, 1000].map { $0 * max(round.valueMultiplier, 1) }

        var categories: [GameState.Category] = selected.map { definition in
            let clues = makeClues(for: definition, baseValues: baseValues, using: &rng)
            return GameState.Category(title: definition.title, isDogCategory: definition.isDogCategory, clues: clues)
        }

        assignSpecialClues(round: round, in: &categories, using: &rng)
        return categories
    }

    private static func makeClues<T: RandomNumberGenerator>(for definition: CategoryDefinition, baseValues: [Int], using rng: inout T) -> [GameState.Clue] {
        let candidates = Array(definition.clues.shuffled(using: &rng).prefix(baseValues.count))
        return zip(baseValues, candidates).map { value, pair in
            GameState.Clue(category: definition.title, value: value, question: pair.question, answer: pair.answer)
        }
    }

    private static func assignSpecialClues<T: RandomNumberGenerator>(round: GameState.Round, in categories: inout [GameState.Category], using rng: inout T) {
        guard !categories.isEmpty else { return }

        let flatIndices: [(cat: Int, clue: Int)] = categories.enumerated().flatMap { column, category in
            category.clues.indices.map { (column, $0) }
        }

        func mark(_ indices: [(cat: Int, clue: Int)], as type: SpecialType) {
            for index in indices {
                switch type {
                case .dailyDouble:
                    categories[index.cat].clues[index.clue].isDailyDouble = true
                case .dailyDooDoo:
                    categories[index.cat].clues[index.clue].isDailyDooDoo = true
                }
            }
        }

        enum SpecialType { case dailyDouble, dailyDooDoo }

        let dailyDoubleCount = round == .doubleJeopardy ? 2 : (round == .jeopardy ? 1 : 0)
        let dailyDooDooCount = round == .doubleJeopardy ? 2 : (round == .jeopardy ? 1 : 0)

        if dailyDoubleCount > 0 {
            let indices = Array(flatIndices.shuffled(using: &rng).prefix(dailyDoubleCount))
            mark(indices, as: .dailyDouble)
        }

        if dailyDooDooCount > 0 {
            let remaining = flatIndices.filter { !categories[$0.cat].clues[$0.clue].isDailyDouble }
            let indices = Array(remaining.shuffled(using: &rng).prefix(dailyDooDooCount))
            mark(indices, as: .dailyDooDoo)
        }
    }
}
