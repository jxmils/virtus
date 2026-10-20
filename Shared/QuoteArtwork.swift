import Foundation

/// Shared thematic sculptures. These are illustrations of ideas, not likenesses of the quoted authors.
enum QuoteArtwork {
    enum Theme: String, CaseIterable {
        case greekPhilosophy = "greek-philosophy"
        case romanStoics = "roman-stoics"
        case romanStatesmen = "roman-statesmen"
        case spartanCourage = "spartan-courage"
        case ancientCommanders = "ancient-commanders"
        case easternWisdom = "eastern-wisdom"
        case samuraiDiscipline = "samurai-discipline"
        case renaissanceCreativity = "renaissance-creativity"
        case enlightenmentReason = "enlightenment-reason"
        case poetsWriters = "poets-writers"
        case modernResolve = "modern-resolve"
        case athleticExcellence = "athletic-excellence"
        case spiritualWisdom = "spiritual-wisdom"
        case imperialLeadership = "imperial-leadership"
    }

    static let authors: [String: Theme] = {
        let groups: [Theme: [String]] = [
            .greekPhilosophy: ["Antisthenes", "Aristotle", "Democritus", "Diogenes", "Epicurus", "Heraclitus", "Plato", "Pythagoras", "Socrates"],
            .romanStoics: ["Cleanthes", "Epictetus", "Marcus Aurelius", "Musonius Rufus", "Seneca", "Zeno of Citium"],
            .romanStatesmen: ["Appius Claudius Caecus", "Augustus", "Cato the Elder", "Cato the Younger", "Cicero", "Julius Caesar", "Livy", "Plutarch", "Polybius", "Publilius Syrus", "Sallust", "Tacitus", "Vegetius"],
            .spartanCourage: ["A Spartan mother", "Agesilaus II", "Agis II", "Dienekes", "Leonidas", "The Spartans", "Tyrtaeus"],
            .ancientCommanders: ["Alexander the Great", "Chabrias", "Cyrus the Great", "Genghis Khan", "Hannibal", "Pericles", "Pyrrhus of Epirus", "Saladin", "Scipio Africanus", "Themistocles", "Thucydides", "Xenophon"],
            .easternWisdom: ["Chanakya", "Chinese proverb", "Confucius", "Lao Tzu", "Mencius", "Sun Tzu", "Xunzi"],
            .samuraiDiscipline: ["Japanese proverb", "Miyamoto Musashi", "Yamamoto Tsunetomo"],
            .renaissanceCreativity: ["Dante", "Francis Bacon", "Leonardo da Vinci", "Michel de Montaigne", "Michelangelo", "Niccolò Machiavelli", "William Shakespeare"],
            .enlightenmentReason: ["Arthur Schopenhauer", "Baruch Spinoza", "Benjamin Disraeli", "Benjamin Franklin", "Blaise Pascal", "Edmund Burke", "Friedrich Nietzsche", "Immanuel Kant", "Samuel Johnson", "Søren Kierkegaard", "Thomas Carlyle", "Thomas Jefferson"],
            .poetsWriters: ["Albert Camus", "Alfred, Lord Tennyson", "Ernest Hemingway", "Fyodor Dostoevsky", "Henry David Thoreau", "Homer", "Horace", "Jack London", "Johann Wolfgang von Goethe", "John Milton", "Juvenal", "Leo Tolstoy", "Mark Twain", "Ovid", "Ralph Waldo Emerson", "Rudyard Kipling", "Simonides", "Terence", "Virgil", "William Ernest Henley"],
            .modernResolve: ["Abraham Lincoln", "Amelia Earhart", "Booker T. Washington", "Calvin Coolidge", "Charles de Gaulle", "Chesty Puller", "Douglas MacArthur", "Dwight D. Eisenhower", "Emiliano Zapata", "Erwin Rommel", "Frederick Douglass", "George S. Patton", "Georges Danton", "Helen Keller", "Henry Ford", "John D. Rockefeller", "John F. Kennedy", "Mahatma Gandhi", "Martin Luther King Jr.", "Nelson Mandela", "Omar Bradley", "Robert E. Lee", "Stonewall Jackson", "T. E. Lawrence", "Theodore Roosevelt", "Thomas Edison", "Ulysses S. Grant", "Viktor Frankl", "Will Durant", "Winston Churchill"],
            .athleticExcellence: ["Bruce Lee", "Kobe Bryant", "Muhammad Ali", "Vince Lombardi"],
            .spiritualWisdom: ["Boethius", "Latin proverb", "Military proverb", "Proverb", "Rumi", "Saadi", "The Bible"],
            .imperialLeadership: ["Alexander Suvorov", "Carl von Clausewitz", "Charlemagne", "Duke of Wellington", "Elizabeth I", "Frederick the Great", "George Washington", "Helmuth von Moltke", "Horatio Nelson", "Napoleon Bonaparte", "Otto von Bismarck", "Peter the Great"]
        ]
        var result: [String: Theme] = [:]
        for (theme, names) in groups {
            for name in names {
                precondition(result.updateValue(theme, forKey: name) == nil, "Duplicate artwork author: \(name)")
            }
        }
        return result
    }()

    static func theme(for author: String) -> Theme {
        authors[author] ?? .spiritualWisdom
    }
}
