import SwiftUI

struct RootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedSection: AppSection = .dashboard
    @StateObject private var trainerStore = TrainerStore()
    @StateObject private var settings = AppSettings()
    @StateObject private var progressStore = ProgressStore()

    private var contentLayoutDirection: LayoutDirection {
        settings.selectedLanguageCode == AppLanguage.ar.rawValue ? .rightToLeft : .leftToRight
    }

    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                appShell
            } else {
                OnboardingView(settings: settings)
            }
        }
        .environment(\.locale, Locale(identifier: settings.selectedLanguageCode))
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private var appShell: some View {
        Group {
            if horizontalSizeClass == .regular {
                ipadLayout
            } else {
                phoneLayout
            }
        }
    }

    private var phoneLayout: some View {
        TabView(selection: $selectedSection) {
            ForEach(AppSection.allCases) { section in
                NavigationStack {
                    sectionView(for: section)
                }
                .tabItem {
                    Label {
                        Text(LocalizedStringKey(section.titleKey))
                    } icon: {
                        Image(systemName: section.iconName)
                    }
                }
                .tag(section)
            }
        }
        .environment(\.layoutDirection, contentLayoutDirection)
        .tint(AppTheme.brandYellow)
    }

    private var ipadLayout: some View {
        NavigationSplitView {
            List {
                ForEach(AppSection.allCases) { section in
                    Button {
                        selectedSection = section
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: section.iconName)
                                .foregroundStyle(AppTheme.brandYellow)
                            Text(LocalizedStringKey(section.titleKey))
                                .font(.headline)
                            Spacer()
                            if selectedSection == section {
                                Image(systemName: "chevron.right.circle.fill")
                                    .foregroundStyle(Color.white.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(selectedSection == section ? AppTheme.surfaceStrong : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 12)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.backgroundGradient)
            .navigationTitle(Text("app.name"))
            .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 340)
            .environment(\.layoutDirection, .leftToRight)
        } detail: {
            NavigationStack {
                sectionView(for: selectedSection)
                    .environment(\.layoutDirection, contentLayoutDirection)
            }
            .id("ipad-detail-\(selectedSection.rawValue)-\(settings.selectedLanguageCode)")
        }
        .navigationSplitViewStyle(.balanced)
        .tint(AppTheme.brandYellow)
    }

    @ViewBuilder
    private func sectionView(for section: AppSection) -> some View {
        switch section {
        case .dashboard:
            DashboardView(progressStore: progressStore)
        case .learn:
            LearnView(progressStore: progressStore)
        case .trainer:
            TrainerView(store: trainerStore, settings: settings, progressStore: progressStore)
        case .history:
            HistoryView()
        case .settings:
            SettingsView(settings: settings, progressStore: progressStore)
        }
    }
}

struct OnboardingView: View {
    @ObservedObject var settings: AppSettings
    @State private var pageIndex = 0

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("app.name")
                        .font(.title2.weight(.bold))
                    Spacer()
                    Text("\(pageIndex + 1)/\(AppData.onboardingPages.count)")
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 18) {
                    Image(systemName: AppData.onboardingPages[pageIndex].symbol)
                        .font(.system(size: 42))
                        .foregroundStyle(AppTheme.brandYellow)

                    Text(LocalizedStringKey(AppData.onboardingPages[pageIndex].titleKey))
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    Text(LocalizedStringKey(AppData.onboardingPages[pageIndex].bodyKey))
                        .foregroundStyle(AppTheme.textSecondary)
                        .font(.body.leading(.loose))
                }
                .padding(28)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.heroGradient, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

                HStack(spacing: 10) {
                    ForEach(0..<AppData.onboardingPages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == pageIndex ? AppTheme.brandYellow : Color.white.opacity(0.16))
                            .frame(width: index == pageIndex ? 34 : 12, height: 10)
                    }
                }

                Spacer()

                HStack {
                    if pageIndex > 0 {
                        Button("onboarding.back") {
                            pageIndex -= 1
                        }
                        .buttonStyle(.bordered)
                        .tint(AppTheme.brandYellow)
                    }

                    Spacer()

                    Button(pageIndex == AppData.onboardingPages.count - 1 ? String(localized: "onboarding.start") : String(localized: "onboarding.next")) {
                        if pageIndex == AppData.onboardingPages.count - 1 {
                            settings.hasCompletedOnboarding = true
                        } else {
                            pageIndex += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.brandYellow)
                    .foregroundStyle(.black)
                }
            }
            .padding(24)
        }
    }
}

struct DashboardView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var progressStore: ProgressStore

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: horizontalSizeClass == .regular ? 280 : 220), spacing: 16)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroCard

                HStack(spacing: 12) {
                    progressPill(titleKey: "progress.streak", value: "\(progressStore.streakDays)")
                    progressPill(titleKey: "progress.saved", value: "\(progressStore.savedLessonsCount)")
                    progressPill(titleKey: "progress.highScore", value: "\(progressStore.highScore)")
                }

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AppData.dashboardHighlights) { highlight in
                        VStack(alignment: .leading, spacing: 14) {
                            Image(systemName: highlight.symbol)
                                .font(.title2)
                                .foregroundStyle(AppTheme.brandYellow)

                            Text(LocalizedStringKey(highlight.titleKey))
                                .font(.title3.weight(.semibold))

                            Text(LocalizedStringKey(highlight.bodyKey))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appCard()
                    }
                }

                todayFocusCard
                achievementsCard
            }
            .padding(20)
        }
        .navigationTitle(Text("dashboard.nav"))
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image("DashboardHero")
                .resizable()
                .scaledToFill()
                .frame(height: 360)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.82)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 14) {
                Text("dashboard.hero.eyebrow")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(AppTheme.brandYellow)

                Text("dashboard.hero.title")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text("dashboard.hero.subtitle")
                    .foregroundStyle(AppTheme.textSecondary)
                    .font(.body.leading(.loose))

                HStack(spacing: 12) {
                    statPill(titleKey: "dashboard.stat.players", value: "3")
                    statPill(titleKey: "dashboard.stat.touchLimit", value: "3")
                    statPill(titleKey: "dashboard.stat.focus", value: "360°")
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.heroGradient, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var todayFocusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("dashboard.focus.title")
                .font(.title3.weight(.semibold))
            Text("dashboard.focus.body")
                .foregroundStyle(AppTheme.textSecondary)
            Divider().overlay(Color.white.opacity(0.08))
            Label("dashboard.focus.drill", systemImage: "figure.mind.and.body")
                .font(.body.weight(.medium))
            Text("dashboard.focus.drill.body")
                .foregroundStyle(AppTheme.textSecondary)
        }
        .appCard()
    }

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("dashboard.achievements.title")
                    .font(.title3.weight(.semibold))
                Spacer()
                Text("\(progressStore.achievementsCount)/\(AppData.achievements.count)")
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ForEach(AppData.achievements) { achievement in
                HStack(spacing: 14) {
                    Image(systemName: achievement.symbol)
                        .foregroundStyle(progressStore.unlockedAchievements.contains(achievement.id) ? AppTheme.brandYellow : Color.white.opacity(0.35))
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedStringKey(achievement.titleKey))
                            .font(.headline)
                        Text(LocalizedStringKey(achievement.bodyKey))
                            .foregroundStyle(AppTheme.textSecondary)
                            .font(.subheadline)
                    }
                    Spacer()
                }
            }
        }
        .appCard()
    }

    private func statPill(titleKey: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.black)
            Text(LocalizedStringKey(titleKey))
                .font(.caption)
                .foregroundStyle(.black.opacity(0.75))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.brandYellow, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func progressPill(titleKey: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey(titleKey))
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.title3.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}

struct LearnView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var progressStore: ProgressStore

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: horizontalSizeClass == .regular ? 320 : 260), spacing: 16)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionIntroView(
                    eyebrowKey: "learn.eyebrow",
                    titleKey: "learn.title",
                    bodyKey: "learn.subtitle"
                )

                Image("LearnCourt")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )

                bookmarkedSummary
                contentRibbon

                Text("Long-form pathways")
                    .font(.title2.weight(.bold))

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AppData.learnTopics) { topic in
                        NavigationLink {
                            LearnTopicDetailView(topic: topic, progressStore: progressStore)
                        } label: {
                            topicCard(topic)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(Text("learn.nav"))
    }

    private var bookmarkedSummary: some View {
        HStack {
            Label("learn.saved.header", systemImage: "bookmark.fill")
                .font(.headline)
            Spacer()
            Text("\(progressStore.savedLessonsCount)")
                .foregroundStyle(AppTheme.brandYellow)
                .font(.headline)
        }
        .appCard()
    }

    private var contentRibbon: some View {
        HStack(spacing: 12) {
            editorialPill(value: "\(AppData.learnTopics.count)", label: "guided articles")
            editorialPill(value: "3", label: "replay stages")
            editorialPill(value: "10+", label: "related paths")
        }
    }

    private func topicCard(_ topic: LearnTopic) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(topic.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            HStack(alignment: .top) {
                Label(topic.title, systemImage: topic.symbol)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text(topic.readingTime)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.brandYellow)
                    Image(systemName: progressStore.isLessonSaved(topic.id) ? "bookmark.fill" : "chevron.right.circle.fill")
                        .foregroundStyle(progressStore.isLessonSaved(topic.id) ? AppTheme.brandYellow : Color.white.opacity(0.7))
                }
            }

            Text(topic.summary)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private func editorialPill(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title3.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}

struct LearnTopicDetailView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let topic: LearnTopic
    @ObservedObject var progressStore: ProgressStore

    private var relatedTopics: [LearnTopic] {
        topic.relatedIDs.compactMap(AppData.learnTopic(withID:))
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    DetailHeroImage(name: topic.imageName, title: topic.title, summary: topic.summary)

                    HStack {
                        Label("Editorial lesson", systemImage: topic.symbol)
                            .font(.headline)
                        Spacer()
                        Text(topic.readingTime)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.brandYellow)
                        Button {
                            progressStore.toggleSavedLesson(topic.id)
                        } label: {
                            Label(progressStore.isLessonSaved(topic.id) ? "learn.detail.saved" : "learn.detail.save", systemImage: progressStore.isLessonSaved(topic.id) ? "bookmark.fill" : "bookmark")
                        }
                        .buttonStyle(.bordered)
                        .tint(AppTheme.brandYellow)
                    }
                    .appCard()

                    if horizontalSizeClass == .regular {
                        HStack(alignment: .top, spacing: 20) {
                            VStack(alignment: .leading, spacing: 18) {
                                InlineGallerySection(title: "Inline gallery", assets: topic.gallery)
                                ArticleParagraphSection(paragraphs: topic.paragraphs)
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)

                            VStack(alignment: .leading, spacing: 18) {
                                ArticleHighlightSection(title: "What to lock in", items: topic.highlights, systemImage: "checkmark.seal.fill")
                                TimelineSection(title: "Learning flow", entries: topic.timeline)
                                RelatedLearnSection(topics: relatedTopics, progressStore: progressStore)
                            }
                            .frame(width: min(max(proxy.size.width * 0.32, 320), 380), alignment: .topLeading)
                        }
                    } else {
                        ArticleHighlightSection(title: "What to lock in", items: topic.highlights, systemImage: "checkmark.seal.fill")
                        InlineGallerySection(title: "Inline gallery", assets: topic.gallery)
                        TimelineSection(title: "Learning flow", entries: topic.timeline)
                        ArticleParagraphSection(paragraphs: topic.paragraphs)
                        RelatedLearnSection(topics: relatedTopics, progressStore: progressStore)
                    }
                }
                .frame(width: min(max(proxy.size.width - 32, 0), horizontalSizeClass == .regular ? 1120 : max(proxy.size.width - 32, 0)), alignment: .topLeading)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TrainerView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var store: TrainerStore
    @ObservedObject var settings: AppSettings
    @ObservedObject var progressStore: ProgressStore

    private var currentReplayNote: String {
        store.currentScenario.replayNotes[min(store.replayStep, store.currentScenario.replayNotes.count - 1)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionIntroView(
                    eyebrowKey: "trainer.eyebrow",
                    titleKey: "trainer.title",
                    bodyKey: "trainer.subtitle"
                )

                Picker("trainer.difficulty", selection: $store.difficulty) {
                    ForEach(TrainerDifficulty.allCases) { difficulty in
                        Text(LocalizedStringKey(difficulty.titleKey))
                            .tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)

                HStack(spacing: 12) {
                    scoreCard(titleKey: "trainer.score", value: "\(store.sessionScore)")
                    scoreCard(titleKey: "trainer.combo", value: "\(store.combo)")
                    scoreCard(titleKey: "trainer.progress", value: store.progressText)
                }

                if horizontalSizeClass == .regular {
                    HStack(alignment: .top, spacing: 20) {
                        VStack(alignment: .leading, spacing: 20) {
                            situationSummaryCard
                            courtCard
                            replayPanel
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                        scenarioCard
                            .frame(width: 380, alignment: .topLeading)
                    }
                } else {
                    situationSummaryCard
                    courtCard
                    replayPanel
                    scenarioCard
                }
            }
            .padding(20)
        }
        .navigationTitle(Text("trainer.nav"))
    }

    private var situationSummaryCard: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                Text(LocalizedStringKey(store.currentScenario.role.titleKey))
            }
            Spacer()
            zoneTag(title: "Pressure", value: store.currentScenario.ballZone.label)
            zoneTag(title: "Target", value: store.currentScenario.targetZone.label)
        }
        .font(.subheadline)
        .appCard()
    }

    private var courtCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Coach board", systemImage: "sportscourt.fill")
                    .font(.headline)
                Spacer()
                Text(stepTitle(for: store.replayStep))
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.brandYellow.opacity(0.16), in: Capsule())
                    .foregroundStyle(AppTheme.brandYellow)
            }

            CourtSituationView(
                role: store.currentScenario.role,
                ballZone: store.currentScenario.ballZone,
                targetZone: store.currentScenario.targetZone,
                replayStep: store.replayStep
            )
            .frame(height: 320)

            Text(currentReplayNote)
                .foregroundStyle(AppTheme.textSecondary)
                .font(.body.leading(.loose))
        }
        .appCard()
    }

    private var replayPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Replay controls")
                    .font(.headline)
                Spacer()
                Button(store.isReplayPlaying ? "Pause" : "Play replay") {
                    store.toggleReplay()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.brandYellow)
                .foregroundStyle(.black)
            }

            HStack(spacing: 12) {
                Button {
                    store.previousReplayStep()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.brandYellow)

                Button {
                    store.nextReplayStep()
                } label: {
                    Label("Forward", systemImage: "chevron.right")
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.brandYellow)
            }

            HStack(spacing: 12) {
                ReplayStepCard(index: 0, title: "Read", detail: store.currentScenario.replayNotes[0], isActive: store.replayStep == 0)
                ReplayStepCard(index: 1, title: "Shape", detail: store.currentScenario.replayNotes[1], isActive: store.replayStep == 1)
                ReplayStepCard(index: 2, title: "Finish", detail: store.currentScenario.replayNotes[2], isActive: store.replayStep == 2)
            }
        }
        .appCard()
    }

    private var scenarioCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(LocalizedStringKey(store.currentScenario.titleKey))
                    .font(.title3.weight(.semibold))
                Spacer()
                Text(LocalizedStringKey(store.difficulty.titleKey))
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.brandYellow.opacity(0.16), in: Capsule())
                    .foregroundStyle(AppTheme.brandYellow)
            }

            Text(LocalizedStringKey(store.currentScenario.promptKey))
                .foregroundStyle(AppTheme.textSecondary)

            VStack(spacing: 12) {
                ForEach(Array(store.currentScenario.optionKeys.enumerated()), id: \.offset) { index, optionKey in
                    Button {
                        store.choose(index)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(buttonBackground(for: index))
                                    .frame(width: 34, height: 34)
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundStyle(iconColor(for: index))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(LocalizedStringKey(optionKey))
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(AppTheme.textPrimary)
                                if store.selectedIndex == index {
                                    Text(LocalizedStringKey(store.selectedIndex == store.currentScenario.correctIndex ? "trainer.option.correct" : "trainer.option.incorrect"))
                                        .font(.caption)
                                        .foregroundStyle(iconColor(for: index))
                                }
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(buttonBorder(for: index), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            if settings.coachHintsEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("trainer.feedback")
                        .font(.headline)
                    Text(feedbackText)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.surfaceStrong, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            HStack {
                Button("trainer.reset") {
                    store.resetSession()
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.brandYellow)

                Spacer()

                Button(store.scenarioIndex == store.scenariosForDifficulty.count - 1 ? String(localized: "trainer.finish") : String(localized: "trainer.next")) {
                    store.advance(settings: settings, progressStore: progressStore)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.brandYellow)
                .foregroundStyle(.black)
                .disabled(!store.isAnswered)
            }
        }
        .appCard()
    }

    private var feedbackText: LocalizedStringKey {
        if let selectedIndex = store.selectedIndex {
            return selectedIndex == store.currentScenario.correctIndex
                ? LocalizedStringKey(store.currentScenario.feedbackKey)
                : "trainer.tryAgainHint"
        }
        return "trainer.feedback.placeholder"
    }

    private func scoreCard(titleKey: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey(titleKey))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.title2.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private func iconColor(for index: Int) -> Color {
        guard let selectedIndex = store.selectedIndex else { return .white }
        if index == store.currentScenario.correctIndex { return AppTheme.brandYellow }
        if selectedIndex == index { return .red.opacity(0.82) }
        return .white.opacity(0.5)
    }

    private func buttonBackground(for index: Int) -> Color {
        guard let selectedIndex = store.selectedIndex else { return Color.white.opacity(0.08) }
        if index == store.currentScenario.correctIndex { return AppTheme.brandYellow.opacity(0.18) }
        if selectedIndex == index { return Color.red.opacity(0.16) }
        return Color.white.opacity(0.05)
    }

    private func buttonBorder(for index: Int) -> Color {
        guard let selectedIndex = store.selectedIndex else { return Color.white.opacity(0.1) }
        if index == store.currentScenario.correctIndex { return AppTheme.brandYellow.opacity(0.9) }
        if selectedIndex == index { return Color.red.opacity(0.7) }
        return Color.white.opacity(0.08)
    }

    private func stepTitle(for step: Int) -> String {
        switch step {
        case 0: "Read"
        case 1: "Shape"
        default: "Finish"
        }
    }

    private func zoneTag(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct CourtSituationView: View {
    let role: TakrawRole
    let ballZone: CourtZone
    let targetZone: CourtZone
    let replayStep: Int

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let leftFront = CGPoint(x: width * 0.26, y: height * 0.74)
            let rightFront = CGPoint(x: width * 0.74, y: height * 0.74)
            let service = CGPoint(x: width * 0.5, y: height * 0.22)
            let netY = height * 0.48
            let start = point(for: ballZone, service: service, leftFront: leftFront, rightFront: rightFront, width: width, netY: netY)
            let rolePoint = point(for: role, service: service, leftFront: leftFront, rightFront: rightFront)
            let end = point(for: targetZone, service: service, leftFront: leftFront, rightFront: rightFront, width: width, netY: netY)
            let activeBallPoint = replayPoint(step: replayStep, start: start, rolePoint: rolePoint, end: end)

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.03), AppTheme.brandYellow.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)

                Path { path in
                    path.addRoundedRect(in: CGRect(x: width * 0.08, y: height * 0.1, width: width * 0.84, height: height * 0.8), cornerSize: CGSize(width: 22, height: 22))
                }
                .stroke(Color.white.opacity(0.18), lineWidth: 2)

                Path { path in
                    path.move(to: CGPoint(x: width * 0.08, y: netY))
                    path.addLine(to: CGPoint(x: width * 0.92, y: netY))
                }
                .stroke(Color.white.opacity(0.75), style: StrokeStyle(lineWidth: 3, dash: [6, 6]))

                courtCircle(center: service)
                courtCircle(center: leftFront)
                courtCircle(center: rightFront)

                playerNode(titleKey: "learn.role.tekong.title", role: .tekong, point: service)
                playerNode(titleKey: "learn.role.feeder.title", role: .feeder, point: leftFront)
                playerNode(titleKey: "learn.role.killer.title", role: .killer, point: rightFront)

                stepPath(from: start, to: rolePoint, isActive: replayStep >= 1)
                stepPath(from: rolePoint, to: end, isActive: replayStep >= 2)

                marker(title: "Pressure", point: start, tint: .white.opacity(0.75))
                marker(title: "Target", point: end, tint: AppTheme.brandYellow.opacity(0.8))

                Circle()
                    .fill(AppTheme.brandYellow)
                    .frame(width: 22, height: 22)
                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 2))
                    .shadow(color: AppTheme.brandYellow.opacity(0.55), radius: 18)
                    .position(activeBallPoint)
                    .animation(.easeInOut(duration: 0.5), value: replayStep)
            }
        }
    }

    private func courtCircle(center: CGPoint) -> some View {
        Circle()
            .stroke(Color.white.opacity(0.9), lineWidth: 2)
            .frame(width: 74, height: 74)
            .position(center)
    }

    private func playerNode(titleKey: String, role: TakrawRole, point: CGPoint) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill(self.role == role ? AppTheme.brandYellow : Color.white.opacity(0.15))
                .frame(width: 26, height: 26)
                .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
            Text(LocalizedStringKey(titleKey))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white)
        }
        .position(point)
    }

    private func marker(title: String, point: CGPoint, tint: Color) -> some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.5), in: Capsule())
            .foregroundStyle(tint)
            .position(x: point.x, y: point.y - 34)
    }

    private func stepPath(from start: CGPoint, to end: CGPoint, isActive: Bool) -> some View {
        Path { path in
            path.move(to: start)
            path.addQuadCurve(to: end, control: CGPoint(x: (start.x + end.x) * 0.5, y: min(start.y, end.y) - 44))
        }
        .stroke(
            isActive ? AppTheme.brandYellow : Color.white.opacity(0.15),
            style: StrokeStyle(lineWidth: isActive ? 4 : 2, lineCap: .round, dash: [10, 8])
        )
    }

    private func replayPoint(step: Int, start: CGPoint, rolePoint: CGPoint, end: CGPoint) -> CGPoint {
        switch step {
        case 0: start
        case 1: rolePoint
        default: end
        }
    }

    private func point(for role: TakrawRole, service: CGPoint, leftFront: CGPoint, rightFront: CGPoint) -> CGPoint {
        switch role {
        case .tekong: service
        case .feeder: leftFront
        case .killer: rightFront
        }
    }

    private func point(for zone: CourtZone, service: CGPoint, leftFront: CGPoint, rightFront: CGPoint, width: CGFloat, netY: CGFloat) -> CGPoint {
        switch zone {
        case .service: service
        case .leftFront: leftFront
        case .rightFront: rightFront
        case .net: CGPoint(x: width * 0.5, y: netY - 10)
        case .center: CGPoint(x: width * 0.5, y: netY + 72)
        }
    }
}

struct ReplayStepCard: View {
    let index: Int
    let title: String
    let detail: String
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(index + 1)")
                    .font(.caption.weight(.bold))
                    .padding(8)
                    .background((isActive ? AppTheme.brandYellow : Color.white.opacity(0.08)), in: Circle())
                    .foregroundStyle(isActive ? .black : .white)
                Text(title)
                    .font(.headline)
            }

            Text(detail)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isActive ? AppTheme.brandYellow.opacity(0.12) : Color.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isActive ? AppTheme.brandYellow.opacity(0.8) : Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct HistoryView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: horizontalSizeClass == .regular ? 320 : 260), spacing: 16)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionIntroView(
                    eyebrowKey: "history.eyebrow",
                    titleKey: "history.title",
                    bodyKey: "history.subtitle"
                )

                Image("HistoryOrigins")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )

                HStack(spacing: 12) {
                    historyPill(value: "\(AppData.historyStories.count)", label: "curated stories")
                    historyPill(value: "5", label: "eras and themes")
                    historyPill(value: "3", label: "gallery beats")
                }

                Text("Tap into full cultural stories")
                    .font(.title2.weight(.bold))

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AppData.historyStories) { story in
                        NavigationLink {
                            HistoryStoryDetailView(story: story)
                        } label: {
                            historyCard(story)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle(Text("history.nav"))
    }

    private func historyCard(_ story: HistoryStory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(story.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            HStack {
                Text(story.accentLabel)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.brandYellow.opacity(0.16), in: Capsule())
                    .foregroundStyle(AppTheme.brandYellow)
                Spacer()
                Text(story.readingTime)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Text(story.title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(story.summary)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private func historyPill(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title3.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}

struct HistoryStoryDetailView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let story: HistoryStory

    private var relatedStories: [HistoryStory] {
        story.relatedIDs.compactMap(AppData.historyStory(withID:))
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    DetailHeroImage(name: story.imageName, title: story.title, summary: story.summary)

                    HStack {
                        Label("Cultural feature", systemImage: "globe.asia.australia.fill")
                            .font(.headline)
                        Spacer()
                        Text(story.readingTime)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.brandYellow)
                    }
                    .appCard()

                    if horizontalSizeClass == .regular {
                        HStack(alignment: .top, spacing: 20) {
                            VStack(alignment: .leading, spacing: 18) {
                                InlineGallerySection(title: "Inline gallery", assets: story.gallery)
                                ArticleParagraphSection(paragraphs: story.paragraphs)
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)

                            VStack(alignment: .leading, spacing: 18) {
                                ArticleHighlightSection(title: "Key historical takeaways", items: story.highlights, systemImage: "circle.grid.cross.fill")
                                TimelineSection(title: "Timeline", entries: story.timeline)
                                RelatedHistorySection(stories: relatedStories)
                            }
                            .frame(width: min(max(proxy.size.width * 0.32, 320), 380), alignment: .topLeading)
                        }
                    } else {
                        ArticleHighlightSection(title: "Key historical takeaways", items: story.highlights, systemImage: "circle.grid.cross.fill")
                        InlineGallerySection(title: "Inline gallery", assets: story.gallery)
                        TimelineSection(title: "Timeline", entries: story.timeline)
                        ArticleParagraphSection(paragraphs: story.paragraphs)
                        RelatedHistorySection(stories: relatedStories)
                    }
                }
                .frame(width: min(max(proxy.size.width - 32, 0), horizontalSizeClass == .regular ? 1120 : max(proxy.size.width - 32, 0)), alignment: .topLeading)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(story.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var progressStore: ProgressStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionIntroView(
                    eyebrowKey: "settings.eyebrow",
                    titleKey: "settings.title",
                    bodyKey: "settings.subtitle"
                )

                VStack(alignment: .leading, spacing: 16) {
                    Text("settings.language.header")
                        .font(.headline)

                    Picker("settings.language.label", selection: $settings.selectedLanguageCode) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(LocalizedStringKey(language.titleKey))
                                .tag(language.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .appCard()

                VStack(alignment: .leading, spacing: 14) {
                    Toggle("settings.coachHints", isOn: $settings.coachHintsEnabled)
                    Toggle("settings.autoSave", isOn: $settings.autoSaveCorrectLessons)
                }
                .toggleStyle(.switch)
                .appCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("settings.progress.header")
                        .font(.headline)
                    HStack {
                        Label("\(progressStore.streakDays)", systemImage: "flame.fill")
                        Spacer()
                        Label("\(progressStore.savedLessonsCount)", systemImage: "bookmark.fill")
                        Spacer()
                        Label("\(progressStore.achievementsCount)", systemImage: "crown.fill")
                    }
                    .foregroundStyle(AppTheme.brandYellow)
                }
                .appCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("settings.actions.header")
                        .font(.headline)

                    Button("settings.resetOnboarding") {
                        settings.resetOnboarding()
                    }
                    .buttonStyle(.bordered)
                    .tint(AppTheme.brandYellow)

                    Button("settings.resetProgress") {
                        progressStore.resetAll()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .appCard()

                VStack(alignment: .leading, spacing: 8) {
                    Text("settings.appInfo.header")
                        .font(.headline)
                    Text(appInfoLine)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("settings.appInfo.body")
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .appCard()
            }
            .padding(20)
        }
        .navigationTitle(Text("settings.nav"))
    }

    private var appInfoLine: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return String(localized: "settings.versionPrefix") + " \(version)"
    }
}

struct ArticleHighlightSection: View {
    let title: String
    let items: [String]
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: systemImage)
                        .foregroundStyle(AppTheme.brandYellow)
                        .padding(.top, 2)
                    Text(item)
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCard()
            }
        }
    }
}

struct InlineGallerySection: View {
    let title: String
    let assets: [GalleryAsset]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(assets) { asset in
                        VStack(alignment: .leading, spacing: 10) {
                            Image(asset.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 280, height: 180)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                            Text(asset.caption)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .frame(width: 280, alignment: .leading)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .appCard()
    }
}

struct TimelineSection: View {
    let title: String
    let entries: [ArticleTimelineEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)

            ForEach(entries) { entry in
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 8) {
                        Text(entry.label)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(AppTheme.brandYellow, in: Capsule())
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 2, height: 52)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(entry.title)
                            .font(.headline)
                        Text(entry.body)
                            .foregroundStyle(AppTheme.textSecondary)
                            .font(.subheadline.leading(.loose))
                    }

                    Spacer()
                }
                .appCard()
            }
        }
    }
}

struct ArticleParagraphSection: View {
    let paragraphs: [String]

    var body: some View {
        ForEach(paragraphs, id: \.self) { paragraph in
            Text(paragraph)
                .foregroundStyle(AppTheme.textSecondary)
                .font(.body.leading(.loose))
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCard()
        }
    }
}

struct RelatedLearnSection: View {
    let topics: [LearnTopic]
    @ObservedObject var progressStore: ProgressStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related topics")
                .font(.headline)

            ForEach(topics) { topic in
                NavigationLink {
                    LearnTopicDetailView(topic: topic, progressStore: progressStore)
                } label: {
                    HStack(spacing: 14) {
                        Image(topic.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 82, height: 72)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(topic.title)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text(topic.summary)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        Image(systemName: progressStore.isLessonSaved(topic.id) ? "bookmark.fill" : "chevron.right")
                            .foregroundStyle(progressStore.isLessonSaved(topic.id) ? AppTheme.brandYellow : Color.white.opacity(0.6))
                    }
                    .appCard()
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct RelatedHistorySection: View {
    let stories: [HistoryStory]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related topics")
                .font(.headline)

            ForEach(stories) { story in
                NavigationLink {
                    HistoryStoryDetailView(story: story)
                } label: {
                    HStack(spacing: 14) {
                        Image(story.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 82, height: 72)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(story.title)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text(story.summary)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                    .appCard()
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct DetailHeroImage: View {
    let name: String
    let title: String
    let summary: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(height: 280)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.84)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Text(summary)
                    .foregroundStyle(Color.white.opacity(0.82))
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipped()
    }
}

struct SectionIntroView: View {
    let eyebrowKey: String
    let titleKey: String
    let bodyKey: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey(eyebrowKey))
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(AppTheme.brandYellow)

            Text(LocalizedStringKey(titleKey))
                .font(.system(size: 30, weight: .bold, design: .rounded))

            Text(LocalizedStringKey(bodyKey))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }
}
