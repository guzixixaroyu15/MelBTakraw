import Foundation

enum AppSection: String, CaseIterable, Identifiable {
    case dashboard
    case learn
    case trainer
    case history
    case settings

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .dashboard: "tab.dashboard"
        case .learn: "tab.learn"
        case .trainer: "tab.trainer"
        case .history: "tab.history"
        case .settings: "tab.settings"
        }
    }

    var iconName: String {
        switch self {
        case .dashboard: "sparkles.rectangle.stack"
        case .learn: "book.closed"
        case .trainer: "target"
        case .history: "clock.arrow.trianglehead.counterclockwise.rotate.90"
        case .settings: "slider.horizontal.3"
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case en
    case es
    case de
    case ar
    case th

    var id: String { rawValue }

    var localeIdentifier: String { rawValue }

    var titleKey: String {
        switch self {
        case .en: "language.english"
        case .es: "language.spanish"
        case .de: "language.german"
        case .ar: "language.arabic"
        case .th: "language.thai"
        }
    }
}

enum TrainerDifficulty: String, CaseIterable, Identifiable {
    case starter
    case challenger
    case elite

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .starter: "difficulty.starter"
        case .challenger: "difficulty.challenger"
        case .elite: "difficulty.elite"
        }
    }

    var points: Int {
        switch self {
        case .starter: 10
        case .challenger: 16
        case .elite: 24
        }
    }
}

enum TakrawRole: String, Identifiable {
    case tekong
    case feeder
    case killer

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .tekong: "learn.role.tekong.title"
        case .feeder: "learn.role.feeder.title"
        case .killer: "learn.role.killer.title"
        }
    }
}

enum CourtZone: String {
    case service
    case leftFront
    case rightFront
    case net
    case center

    var label: String {
        switch self {
        case .service: "Service circle"
        case .leftFront: "Left front lane"
        case .rightFront: "Right front lane"
        case .net: "Net pressure zone"
        case .center: "Recovery center"
        }
    }
}

struct DashboardHighlight: Identifiable {
    let id: String
    let titleKey: String
    let bodyKey: String
    let symbol: String
}

struct GalleryAsset: Identifiable, Hashable {
    let imageName: String
    let caption: String

    var id: String { imageName + caption }
}

struct ArticleTimelineEntry: Identifiable, Hashable {
    let id: String
    let label: String
    let title: String
    let body: String
}

struct LearnTopic: Identifiable {
    let id: String
    let title: String
    let summary: String
    let imageName: String
    let symbol: String
    let readingTime: String
    let paragraphs: [String]
    let highlights: [String]
    let gallery: [GalleryAsset]
    let timeline: [ArticleTimelineEntry]
    let relatedIDs: [String]
}

struct HistoryStory: Identifiable {
    let id: String
    let title: String
    let summary: String
    let imageName: String
    let readingTime: String
    let paragraphs: [String]
    let highlights: [String]
    let gallery: [GalleryAsset]
    let timeline: [ArticleTimelineEntry]
    let relatedIDs: [String]
    let accentLabel: String
}

struct AchievementDefinition: Identifiable {
    let id: String
    let titleKey: String
    let bodyKey: String
    let symbol: String
}

struct OnboardingPage: Identifiable {
    let id: String
    let titleKey: String
    let bodyKey: String
    let symbol: String
}

struct TacticScenario: Identifiable {
    let id: String
    let titleKey: String
    let promptKey: String
    let optionKeys: [String]
    let correctIndex: Int
    let feedbackKey: String
    let difficulty: TrainerDifficulty
    let relatedLessonID: String
    let role: TakrawRole
    let ballZone: CourtZone
    let targetZone: CourtZone
    let replayNotes: [String]
}

enum AppData {
    private static func optionKeys(_ prefix: String) -> [String] {
        (1...3).map { "\(prefix).option.\($0)" }
    }

    private static func gallery(_ items: (String, String)...) -> [GalleryAsset] {
        items.map { GalleryAsset(imageName: $0.0, caption: $0.1) }
    }

    private static func timeline(prefix: String, _ items: (String, String, String)...) -> [ArticleTimelineEntry] {
        items.enumerated().map { index, item in
            ArticleTimelineEntry(
                id: "\(prefix)\(index + 1)",
                label: item.0,
                title: item.1,
                body: item.2
            )
        }
    }

    private static func learnTopic(
        id: String,
        title: String,
        summary: String,
        imageName: String,
        symbol: String,
        readingTime: String,
        paragraphs: [String],
        highlights: [String],
        gallery: [GalleryAsset],
        timeline: [ArticleTimelineEntry],
        relatedIDs: [String]
    ) -> LearnTopic {
        LearnTopic(
            id: id,
            title: title,
            summary: summary,
            imageName: imageName,
            symbol: symbol,
            readingTime: readingTime,
            paragraphs: paragraphs,
            highlights: highlights,
            gallery: gallery,
            timeline: timeline,
            relatedIDs: relatedIDs
        )
    }

    private static func historyStory(
        id: String,
        title: String,
        summary: String,
        imageName: String,
        readingTime: String,
        paragraphs: [String],
        highlights: [String],
        gallery: [GalleryAsset],
        timeline: [ArticleTimelineEntry],
        relatedIDs: [String],
        accentLabel: String
    ) -> HistoryStory {
        HistoryStory(
            id: id,
            title: title,
            summary: summary,
            imageName: imageName,
            readingTime: readingTime,
            paragraphs: paragraphs,
            highlights: highlights,
            gallery: gallery,
            timeline: timeline,
            relatedIDs: relatedIDs,
            accentLabel: accentLabel
        )
    }

    private static func scenario(
        id: String,
        keyPrefix: String,
        correctIndex: Int,
        feedbackKey: String,
        difficulty: TrainerDifficulty,
        relatedLessonID: String,
        role: TakrawRole,
        ballZone: CourtZone,
        targetZone: CourtZone,
        replayNotes: [String]
    ) -> TacticScenario {
        TacticScenario(
            id: id,
            titleKey: "\(keyPrefix).title",
            promptKey: "\(keyPrefix).prompt",
            optionKeys: optionKeys(keyPrefix),
            correctIndex: correctIndex,
            feedbackKey: feedbackKey,
            difficulty: difficulty,
            relatedLessonID: relatedLessonID,
            role: role,
            ballZone: ballZone,
            targetZone: targetZone,
            replayNotes: replayNotes
        )
    }

    static let dashboardHighlights: [DashboardHighlight] = [
        .init(id: "1", titleKey: "dashboard.highlight.analytics.title", bodyKey: "dashboard.highlight.analytics.body", symbol: "chart.line.uptrend.xyaxis"),
        .init(id: "2", titleKey: "dashboard.highlight.roles.title", bodyKey: "dashboard.highlight.roles.body", symbol: "person.3.sequence"),
        .init(id: "3", titleKey: "dashboard.highlight.culture.title", bodyKey: "dashboard.highlight.culture.body", symbol: "globe.asia.australia")
    ]

    static let onboardingPages: [OnboardingPage] = [
        .init(id: "o1", titleKey: "onboarding.page1.title", bodyKey: "onboarding.page1.body", symbol: "sportscourt"),
        .init(id: "o2", titleKey: "onboarding.page2.title", bodyKey: "onboarding.page2.body", symbol: "brain.head.profile"),
        .init(id: "o3", titleKey: "onboarding.page3.title", bodyKey: "onboarding.page3.body", symbol: "globe.badge.chevron.backward")
    ]

    static let learnTopics: [LearnTopic] = [
        learnTopic(
            id: "foundations",
            title: "Court Foundations",
            summary: "Understand the regu, touch economy, and why Sepak Takraw feels so compressed and intelligent from the first serve.",
            imageName: "LearnCourt",
            symbol: "sportscourt.fill",
            readingTime: "7 min read",
            paragraphs: [
                "A regu looks simple on paper: three players, a net, and three touches. In practice, the geometry is unusually dense. The service circle creates a fixed ignition point, the front lanes decide how quickly pressure reaches the net, and the central corridor becomes the emergency route whenever shape begins to break.",
                "This is why beginners often feel overwhelmed in their first watch. The sport hides its logic behind speed. Once you learn to read how the court is divided into service responsibility, front-lane pressure, and central recovery, the rallies stop feeling random and start feeling authored.",
                "Takraw is also ruthless about wasted touches. In a mainstream net sport you may survive a mediocre first contact. Here, an average touch usually creates a chain reaction that forces the next player into a rescue rather than a design choice. The court therefore teaches decision-making before it teaches flair.",
                "For MelB Takraw Lab, this article becomes the user's first editorial anchor. It is the page that teaches them how to see. Once they understand the map of the court, every other screen in the app gains clarity, especially the trainer where lane selection and role spacing drive the challenge."
            ],
            highlights: [
                "Three contacts are not a formality; they are the entire economy of a rally.",
                "Court geometry matters because the smallest shift in body angle can open or close a lane.",
                "The first serve already contains tactical intent, not just the act of starting play."
            ],
            gallery: gallery(
                ("LearnCourt", "Top-down court geometry is the fastest way to make the sport legible."),
                ("ServiceMechanics", "The service circle is not just a mark; it is the launchpad for pressure."),
                ("RattanCraft", "Even the ball's texture shapes how players control pace and height.")
            ),
            timeline: timeline(
                prefix: "lf",
                ("01", "Read the map", "Learn the fixed service point, the two forward lanes, and the recovery center."),
                ("02", "Value each touch", "Notice how every contact either stabilizes shape or accelerates pressure."),
                ("03", "See the lane early", "The best viewers identify where the attack will travel before the final strike.")
            ),
            relatedIDs: ["service_design", "defensive_shapes", "match_iq"]
        ),
        learnTopic(
            id: "roles",
            title: "Role Architecture",
            summary: "Break down Tekong, Feeder, and Killer as a shared system rather than three isolated labels.",
            imageName: "DashboardHero",
            symbol: "person.3.fill",
            readingTime: "8 min read",
            paragraphs: [
                "The Tekong is commonly introduced as the server, but that label is far too narrow. A strong Tekong controls rhythm, emotional momentum, and the opening quality of almost every exchange. Their reliability changes what the opposition expects and how confidently teammates can prepare the second phase.",
                "The Feeder is the cognitive center of the regu. When a touch arrives off-balance, the Feeder's job is to convert disorder into a playable structure. That conversion is where many new viewers finally begin to respect the sport, because it reveals how much invisible creativity lives between the first and final touch.",
                "The Killer receives the spotlight because they finish points in spectacular ways, yet their explosiveness is only possible when the earlier touches build height, timing, and trust. A Killer without support becomes desperate. A Killer with clean support looks inevitable.",
                "Understanding these roles as a chain rather than as separate characters is essential for the product. It lets MelB Takraw Lab explain not only what each athlete does, but how a regu thinks together under stress."
            ],
            highlights: [
                "Tekong controls tempo before the rally even looks dramatic.",
                "Feeder is the playmaking brain that turns instability into structure.",
                "Killer finishes the point, but only after the first two roles manufacture the window."
            ],
            gallery: gallery(
                ("DashboardHero", "The finishing role is visible, but the setup chain behind it matters just as much."),
                ("ServiceMechanics", "The Tekong sets the emotional frame of the rally."),
                ("ChampionshipArena", "At elite level, role clarity often decides who stays composed in long exchanges.")
            ),
            timeline: timeline(
                prefix: "lr",
                ("01", "Open with control", "The Tekong creates a clean, intentional first picture."),
                ("02", "Convert the chaos", "The Feeder restores order and presents the best lane."),
                ("03", "Finish the pattern", "The Killer attacks once timing and spacing are aligned.")
            ),
            relatedIDs: ["match_iq", "defensive_shapes", "foundations"]
        ),
        learnTopic(
            id: "match_iq",
            title: "Match IQ",
            summary: "Understand when elite teams choose control over spectacle and how pressure travels inside a rally.",
            imageName: "ChampionshipArena",
            symbol: "brain.head.profile",
            readingTime: "9 min read",
            paragraphs: [
                "Takraw looks explosive, but elite teams are often at their smartest when they resist the dramatic option. A measured recycle, a delayed setup, or a safe central reset can be more sophisticated than forcing an immediate finish from a compromised body position.",
                "This is the layer where spectators become readers. You start tracking tendencies, seeing which player is under emotional pressure, and noticing when a body shape telegraphs the next lane. The sport rewards anticipation more than reaction.",
                "A great tactical reader also recognizes how quickly pressure can move from one athlete to another. A poor first touch does not just lower the quality of the second; it narrows every future angle and reduces what the Killer can sell as a threat. The whole rally shrinks.",
                "That makes Match IQ the connective tissue between Learn and Trainer. The article teaches the logic in prose, then the trainer asks the user to make those same decisions under visual pressure."
            ],
            highlights: [
                "Not every elite choice is aggressive; many are stabilizing decisions that buy a cleaner future touch.",
                "Body shape often reveals the next lane before the ball is struck.",
                "A rally becomes readable once you track how one weak touch compresses all later options."
            ],
            gallery: gallery(
                ("ChampionshipArena", "Modern Takraw creates visual drama instantly, but understanding requires context."),
                ("LearnCourt", "Court geometry and team shape explain why some calm touches are actually elite."),
                ("DashboardHero", "The highlight finish only makes sense when the previous two decisions are understood.")
            ),
            timeline: timeline(
                prefix: "lm",
                ("01", "Read the pressure point", "Find the athlete or zone where the rally is becoming unstable."),
                ("02", "Preserve optionality", "Strong teams choose touches that keep multiple next actions alive."),
                ("03", "Attack when the lane is earned", "The cleanest finish usually comes after a patient shape reset.")
            ),
            relatedIDs: ["roles", "defensive_shapes", "service_design"]
        ),
        learnTopic(
            id: "service_design",
            title: "Service Design",
            summary: "Explore how serve height, disguise, and first-contact pressure frame the entire point before the crowd notices it.",
            imageName: "ServiceMechanics",
            symbol: "target",
            readingTime: "6 min read",
            paragraphs: [
                "The service in Takraw is not a neutral restart. It is an authored opening move that introduces tempo, trajectory, and emotional pressure in a single action. The best Tekongs are not only accurate; they are persuasive. They make receivers commit early.",
                "Serve design combines body mechanics with tactical storytelling. Small variations in toss rhythm, hip position, and contact height can force the receiving side to alter their shape a half-step earlier than they would prefer. In a sport this compressed, half a step is meaningful.",
                "A useful way to study service is to ask what kind of second touch it creates. An intimidating serve that produces a comfortable first receive is less valuable than a disciplined serve that bends the next contact toward the sideline and disrupts the Feeder's posture.",
                "For the product, this topic gives users a practical bridge between fundamentals and intelligence. It shows that even the earliest touch can be discussed like design, not just technique."
            ],
            highlights: [
                "A serve should be judged by the shape it forces next, not only by how dramatic it looks.",
                "Disguise and timing matter because receivers react before the ball finishes traveling.",
                "Service pressure is the first tactical lever available in every rally."
            ],
            gallery: gallery(
                ("ServiceMechanics", "Service posture creates clues long before the ball crosses the net."),
                ("LearnCourt", "Lane pressure often starts with where the serve pushes the receiving unit."),
                ("ChampionshipArena", "At championship pace, a well-designed serve can decide the emotional tone of a set.")
            ),
            timeline: timeline(
                prefix: "ls",
                ("01", "Shape the toss", "A stable toss helps hide intention and preserve body balance."),
                ("02", "Force the receive", "The best serves bend the first return toward a weaker lane."),
                ("03", "Prepare the third touch", "A quality serve is really an investment in the next two contacts.")
            ),
            relatedIDs: ["foundations", "roles", "match_iq"]
        ),
        learnTopic(
            id: "defensive_shapes",
            title: "Defensive Shapes",
            summary: "Learn how elite regus recover structure, protect the center, and turn desperate moments into live rallies again.",
            imageName: "ChampionshipArena",
            symbol: "shield.lefthalf.filled",
            readingTime: "8 min read",
            paragraphs: [
                "Defense in Takraw is often misunderstood because fans naturally follow the spectacular strike. Yet the teams that last deepest in tournaments are usually the ones that recover shape fastest after a compromised touch. Their defense is not passive; it is architectural.",
                "The first defensive rule is to protect the center of the court without abandoning the front lanes. That balance is difficult because players must keep the possibility of a counter alive while still preparing for another emergency contact. Every step becomes a negotiation between safety and threat.",
                "Strong defensive shapes also rely on trust. A Feeder who knows the Tekong will cover the recovery pocket can risk a smarter redirection. A Killer who recognizes a delayed attack window can transition from rescue mode back into offensive posture without panic.",
                "This topic matters in the app because it gives the trainer more emotional realism. Many scenarios are not about selecting the flashiest option, but about recognizing the one that rebuilds structure most quickly."
            ],
            highlights: [
                "Defense is the art of restoring options, not merely keeping the ball alive.",
                "The central recovery lane is often the hidden priority in unstable rallies.",
                "A good defensive decision preserves the chance to attack on the very next touch."
            ],
            gallery: gallery(
                ("ChampionshipArena", "Elite defense is visible in how quickly a regu reforms its shape."),
                ("DashboardHero", "Even spectacular attacks begin with somebody winning back structure first."),
                ("HistoryOrigins", "The sport's acrobatic identity has always been paired with surprising control.")
            ),
            timeline: timeline(
                prefix: "ld",
                ("01", "Protect the middle", "The first recovery thought is often about reopening the central lane."),
                ("02", "Assign the rescue", "Role trust decides who stabilizes and who prepares the next pattern."),
                ("03", "Counter from balance", "A live rally becomes dangerous again once shape returns.")
            ),
            relatedIDs: ["match_iq", "roles", "foundations"]
        )
    ]

    static let historyStories: [HistoryStory] = [
        historyStory(
            id: "origins",
            title: "Origins and Shared Heritage",
            summary: "Follow how communal kick-based play became one of Southeast Asia's most distinctive modern sports.",
            imageName: "HistoryOrigins",
            readingTime: "8 min read",
            paragraphs: [
                "Before Takraw was formalized for contemporary competition, forms of foot-based ball play already existed across courts, villages, and communal gatherings in Southeast Asia. The modern game is therefore best understood as an inheritance rather than a sudden invention.",
                "That inheritance matters because it explains why the sport still carries more than athletic function. The woven ball, the circular keeping-up traditions, and the cultural memory of public play all contribute to a visual identity that remains recognizably distinct even in high-performance arenas.",
                "For a new global audience, the origin story does important emotional work. It teaches that Takraw is not simply a spectacular niche pastime waiting to be discovered online; it is a sport with a long relationship to social life, ritual, and craft.",
                "MelB Takraw Lab becomes stronger when it treats this history as core product value. The app is not only explaining rules. It is translating a cultural lineage into a premium digital experience."
            ],
            highlights: [
                "Early Takraw-like play was regional and communal before it was standardized.",
                "Craft culture, especially the woven rattan ball, remains part of the sport's identity.",
                "Historical context gives newcomers a reason to care beyond viral clips."
            ],
            gallery: gallery(
                ("HistoryOrigins", "Shared heritage is one of the sport's clearest differentiators."),
                ("VillagePlay", "Community play shaped the rhythm and social meaning of early forms."),
                ("RattanCraft", "The woven ball connects physical play to material tradition.")
            ),
            timeline: timeline(
                prefix: "ho",
                ("15th c.", "Court and community play", "Kick-based ball traditions appear in royal and communal settings across the region."),
                ("Pre-modern", "Shared visual language", "The woven ball and circular exchanges become part of a recognizable cultural form."),
                ("Modern era", "Formal sport emerges", "Competition structures codify a game that still carries older visual memory.")
            ),
            relatedIDs: ["equipment_craft", "regional_power", "sea_games"],
            accentLabel: "Roots"
        ),
        historyStory(
            id: "regional_power",
            title: "Regional Power and National Identity",
            summary: "See how Thailand, Malaysia, and neighboring nations turned Takraw into a visible and deeply felt competitive discipline.",
            imageName: "ChampionshipArena",
            readingTime: "7 min read",
            paragraphs: [
                "Thailand became one of the sport's great modern homes not just through results, but through repetition, visibility, and public confidence. Takraw occupied a familiar place in schools, community life, and media, which made excellence easier to sustain across generations.",
                "Malaysia also played a defining role in organized competition and audience continuity. Together with other Southeast Asian countries, it helped establish Takraw as something larger than isolated exhibition skill. It became a shared regional standard for grace, control, and athletic imagination.",
                "This regional concentration is strategically important for product thinking. It means the sport can feel niche from a Western perspective while still carrying deep cultural relevance and emotional legitimacy in its strongest markets.",
                "A multilingual app built around Takraw therefore has a rare positioning advantage: it can honor existing heartlands while inviting discovery audiences into the sport without flattening its identity."
            ],
            highlights: [
                "Public familiarity, not only medals, helped build national Takraw ecosystems.",
                "Regional pride gave the sport continuity long before global digital discoverability.",
                "A niche global product can still resonate deeply in established Takraw markets."
            ],
            gallery: gallery(
                ("ChampionshipArena", "Modern arenas visualize how regional investment turned Takraw into a major stage sport."),
                ("DashboardHero", "Contemporary athletic spectacle still reflects a distinctly regional lineage."),
                ("VillagePlay", "National strength grows more easily when cultural familiarity already exists.")
            ),
            timeline: timeline(
                prefix: "hr",
                ("Growth", "Institutional support", "Schools, clubs, and events make the sport repeatable across generations."),
                ("Visibility", "National audiences form", "Broadcast familiarity creates stronger recognition and aspiration."),
                ("Identity", "Regional prestige solidifies", "Takraw becomes a point of public pride, not only a competition result.")
            ),
            relatedIDs: ["sea_games", "modern_game", "origins"],
            accentLabel: "SEA"
        ),
        historyStory(
            id: "sea_games",
            title: "SEA Games and Competitive Legitimacy",
            summary: "Track how multi-sport visibility helped Takraw move from regional familiarity to wider competitive recognition.",
            imageName: "ChampionshipArena",
            readingTime: "6 min read",
            paragraphs: [
                "Multi-sport events matter because they change how a discipline is framed in the public imagination. When Takraw appears within a larger competitive ecosystem, it is seen not only as a cultural practice but as a legitimate elite sport with measurable prestige.",
                "The SEA Games provided exactly that stage. The event gave Takraw a repeating structure for comparison, public storytelling, and national investment. It also widened the circle of viewers who might first encounter the sport through a medal narrative before learning its deeper history.",
                "This visibility helped stabilize pathways for athletes and audiences alike. Consistent competition creates heroes, rivalries, and memory, which are crucial ingredients in turning an impressive sport into a retained audience habit.",
                "For MelB Takraw Lab, this matters because product retention often depends on story. Competition history gives users recurring reasons to return to the sport beyond a single highlight reel."
            ],
            highlights: [
                "Multi-sport visibility helps niche disciplines feel institutionally real.",
                "The SEA Games amplified Takraw through medals, rivalries, and repeatable storytelling.",
                "Competitive memory is one of the strongest tools for long-term audience retention."
            ],
            gallery: gallery(
                ("ChampionshipArena", "Arena spectacle gains meaning when it sits inside a recognized championship context."),
                ("HistoryOrigins", "Formal competition did not erase heritage; it amplified it on a new stage."),
                ("DashboardHero", "Modern viewers often meet Takraw through competition before learning its roots.")
            ),
            timeline: timeline(
                prefix: "hs",
                ("Stage", "Shared competition platform", "A multi-sport event gives the discipline a recurring public stage."),
                ("Memory", "Rivalries and heroes form", "Fans retain a sport more easily when it produces repeat stories."),
                ("Legitimacy", "Investment deepens", "Public prestige encourages stronger athlete and institutional pathways.")
            ),
            relatedIDs: ["regional_power", "modern_game", "equipment_craft"],
            accentLabel: "Games"
        ),
        historyStory(
            id: "equipment_craft",
            title: "Craft, Material, and the Rattan Ball",
            summary: "Look at how material culture shapes the visual identity and tactile intelligence of the sport.",
            imageName: "RattanCraft",
            readingTime: "5 min read",
            paragraphs: [
                "Few sports are identified so quickly by a single object as Takraw is by its woven ball. Even before a viewer understands the rules, the texture, pattern, and handmade associations of the ball signal that this sport comes from a specific material tradition.",
                "That material identity is not merely decorative. It shapes the feel of control, the visual rhythm of flight, and the kind of tactile sensitivity players develop. The ball is part of the sport's intelligence, not just its branding.",
                "From a design perspective, this makes Takraw especially attractive for product storytelling. The ball can anchor iconography, loading screens, editorial photography, and tactile metaphors inside the app without feeling forced or generic.",
                "In MelB Takraw Lab, craft culture becomes an advantage. It gives the app a visual vocabulary that feels premium and rooted at the same time."
            ],
            highlights: [
                "The woven ball is both a gameplay object and a cultural symbol.",
                "Material texture influences how the sport looks and feels in motion.",
                "Craft identity gives the product a richer visual language than generic sports apps."
            ],
            gallery: gallery(
                ("RattanCraft", "Material identity can carry both heritage and premium design language."),
                ("HistoryOrigins", "Visual continuity across centuries helps the sport feel unmistakable."),
                ("LearnCourt", "Even tactical learning becomes more memorable when tied to strong visual symbols.")
            ),
            timeline: timeline(
                prefix: "hc",
                ("Material", "Handmade identity", "The ball emerges as a tactile marker of the sport's cultural roots."),
                ("Visual", "Iconic silhouette", "Its woven form helps Takraw stand apart from mainstream ball sports."),
                ("Product", "Design language", "Modern apps can build a premium brand around authentic material cues.")
            ),
            relatedIDs: ["origins", "modern_game", "sea_games"],
            accentLabel: "Craft"
        ),
        historyStory(
            id: "modern_game",
            title: "The Modern Spectacle Gap",
            summary: "Takraw now has world-class visual drama, but still lacks enough premium products that teach viewers what they are watching.",
            imageName: "DashboardHero",
            readingTime: "7 min read",
            paragraphs: [
                "Modern broadcast and social media make Takraw instantly arresting. Acrobatics, impossible recoveries, and fast-twitch timing create clips that stop a scroll even if the viewer has never heard of the sport before.",
                "The problem is conversion. Spectacle alone does not teach understanding. Without context, the viewer remembers the image but cannot explain the decision that made it brilliant. That is where many niche sports lose momentum after first discovery.",
                "MelB Takraw Lab is built precisely for that gap. The app translates highlight energy into repeatable comprehension through editorial content, visual court explanations, and a trainer that asks the user to think like a player rather than only admire one.",
                "This is a stronger product position than competing on generic scores or mainstream stat dashboards. It turns under-served complexity into a premium learning experience."
            ],
            highlights: [
                "Takraw already wins attention visually; it needs better interpretation tools.",
                "Retention happens when spectacle is paired with explanation.",
                "A niche sports app becomes valuable when it teaches context, not just facts."
            ],
            gallery: gallery(
                ("DashboardHero", "The highlight moment is the hook, but product value lives in explanation."),
                ("ChampionshipArena", "Broadcast drama creates discoverability, yet understanding still needs guidance."),
                ("ServiceMechanics", "Even a single serve can become rich once the user knows what to watch for.")
            ),
            timeline: timeline(
                prefix: "hm",
                ("Clip", "Attention arrives", "Viewers notice the athletic spectacle immediately."),
                ("Gap", "Meaning is missing", "Without interpretation, excitement fades after the visual shock."),
                ("Product", "Understanding becomes retention", "A premium learning layer turns curiosity into habit.")
            ),
            relatedIDs: ["sea_games", "regional_power", "equipment_craft"],
            accentLabel: "Now"
        )
    ]

    static let achievements: [AchievementDefinition] = [
        .init(id: "first_save", titleKey: "achievement.firstSave.title", bodyKey: "achievement.firstSave.body", symbol: "bookmark.fill"),
        .init(id: "daily_streak", titleKey: "achievement.dailyStreak.title", bodyKey: "achievement.dailyStreak.body", symbol: "flame.fill"),
        .init(id: "ten_correct", titleKey: "achievement.tenCorrect.title", bodyKey: "achievement.tenCorrect.body", symbol: "target"),
        .init(id: "elite_perfect", titleKey: "achievement.elitePerfect.title", bodyKey: "achievement.elitePerfect.body", symbol: "crown.fill")
    ]

    static let scenarios: [TacticScenario] = [
        scenario(id: "s1", keyPrefix: "trainer.scenario.1", correctIndex: 0, feedbackKey: "trainer.scenario.1.feedback", difficulty: .starter, relatedLessonID: "roles", role: .feeder, ballZone: .leftFront, targetZone: .net, replayNotes: ["The pressure starts on the left front lane, where the first touch is drifting tight to the net.", "As the feeder, your job is to turn a messy receive into a clean attackable picture.", "The winning lane is the fast net set that keeps the killer on time before the block resets."]),
        scenario(id: "s2", keyPrefix: "trainer.scenario.2", correctIndex: 1, feedbackKey: "trainer.scenario.2.feedback", difficulty: .starter, relatedLessonID: "match_iq", role: .killer, ballZone: .rightFront, targetZone: .rightFront, replayNotes: ["The ball is already living on your side, so the first read is about body balance rather than pure reach.", "The setup should preserve your angle so you can attack without losing the lane.", "The right-front finish works because it uses the open picture instead of forcing a cross-body miracle."]),
        scenario(id: "s3", keyPrefix: "trainer.scenario.3", correctIndex: 1, feedbackKey: "trainer.scenario.3.feedback", difficulty: .starter, relatedLessonID: "foundations", role: .tekong, ballZone: .service, targetZone: .service, replayNotes: ["Everything begins in the service circle, where control matters more than flair.", "The serving motion should keep the regu organized for the next touch, not just create speed.", "Holding the service line keeps the opening shape stable and prevents immediate over-rotation."]),
        scenario(id: "s4", keyPrefix: "trainer.scenario.4", correctIndex: 2, feedbackKey: "trainer.scenario.4.feedback", difficulty: .challenger, relatedLessonID: "roles", role: .killer, ballZone: .net, targetZone: .center, replayNotes: ["Net pressure is already high, so the first responsibility is not to over-commit.", "A smart transition touch buys the regu one cleaner frame instead of gambling on a blocked strike.", "Resetting to the center gives the whole team a chance to attack from balance on the next contact."]),
        scenario(id: "s5", keyPrefix: "trainer.scenario.5", correctIndex: 0, feedbackKey: "trainer.scenario.5.feedback", difficulty: .challenger, relatedLessonID: "foundations", role: .feeder, ballZone: .leftFront, targetZone: .center, replayNotes: ["The left lane is crowded, so reading the squeeze early matters.", "The feeder's best touch opens the central recovery channel instead of chasing a low-percentage quick hit.", "That central release restores enough structure for the next athlete to play with options again."]),
        scenario(id: "s6", keyPrefix: "trainer.scenario.6", correctIndex: 2, feedbackKey: "trainer.scenario.6.feedback", difficulty: .challenger, relatedLessonID: "match_iq", role: .feeder, ballZone: .net, targetZone: .rightFront, replayNotes: ["The pressure point is at the tape, where rushed decisions usually collapse the sequence.", "A composed feeder touch bends the play back toward a cleaner right-side picture.", "The right-front target works because it rebuilds timing before the defense can settle."]),
        scenario(id: "s7", keyPrefix: "trainer.scenario.7", correctIndex: 1, feedbackKey: "trainer.scenario.7.feedback", difficulty: .elite, relatedLessonID: "match_iq", role: .tekong, ballZone: .service, targetZone: .rightFront, replayNotes: ["As Tekong, the first read is whether the serve can distort the receiving shape toward the right lane.", "The service action should stay balanced enough to support the next sequence, not only create speed.", "The right-front finish is earned because the opening move already bent the regu into that corridor."]),
        scenario(id: "s8", keyPrefix: "trainer.scenario.8", correctIndex: 2, feedbackKey: "trainer.scenario.8.feedback", difficulty: .elite, relatedLessonID: "foundations", role: .feeder, ballZone: .net, targetZone: .center, replayNotes: ["This is an unstable net moment, so the first task is to keep the rally alive without losing shape entirely.", "The feeder's touch should feel conservative, but it is actually a high-level recovery choice.", "By using the center, the regu resets its geometry and earns another chance to attack on cleaner terms."]),
        scenario(id: "s9", keyPrefix: "trainer.scenario.9", correctIndex: 0, feedbackKey: "trainer.scenario.9.feedback", difficulty: .elite, relatedLessonID: "roles", role: .killer, ballZone: .rightFront, targetZone: .leftFront, replayNotes: ["The play begins with a loaded right side, which invites the defense to lean too heavily in one direction.", "The setup must preserve enough disguise for the killer to attack across the body without telegraphing it early.", "The left-front finish becomes available because the sequence first sold commitment to the opposite side."])
    ]

    static func learnTopic(withID id: String) -> LearnTopic? {
        learnTopics.first { $0.id == id }
    }

    static func historyStory(withID id: String) -> HistoryStory? {
        historyStories.first { $0.id == id }
    }
}
