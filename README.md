### Detailed Overview of Corgi Jeopardy

Corgi Jeopardy is a delightful, themed trivia game for iOS, built using SpriteKit, that reimagines the classic TV game show Jeopardy! with a whimsical twist: all hosts and players are adorable corgis. The game combines engaging trivia gameplay with charming animations, puns, and dog-related humor to create a fun, lighthearted experience. Players compete in a Jeopardy-style format, selecting clues from a board of categories, buzzing in to answer questions in the form of answers (where responses must be phrased as questions), and wagering on special events. To infuse the theme, 1-3 categories per round are dedicated to corgi or dog topics, filled with playful puns (e.g., "What is a 'paws-itive' attitude?" for a clue about optimism in dogs). The game features corgi characters as the host (a wise, bow-tie-wearing corgi named "Alex Barkman") and players (customizable corgi avatars for the human player and AI opponents).

The core gameplay mirrors Jeopardy!:
- **Rounds**: Jeopardy! (standard values: $200-$1000), Double Jeopardy! (doubled values: $400-$2000), and Final Jeopardy! (wager-based finale).
- **Board**: 6 categories with 5 clues each, revealed as players select them.
- **Answering**: Clues are presented as statements; players must respond in question form (e.g., Clue: "This breed is known for its short legs and long body." Answer: "What is a corgi?").
- **Players**: Single-player mode against 1-2 AI corgi opponents, with optional local multiplayer (2-3 players on one device). AI opponents have varying difficulty levels (easy: slow buzzing, frequent wrong answers; hard: quick and accurate).
- **Scoring**: Start with $0; correct answers add the clue's value, incorrect subtract it. Buzzing in is simulated via tap timing.
- **Special Features**:
  - **Daily Double**: Hidden in the board; player wagers their own score before seeing the clue.
  - **Daily Doo-Doo**: A unique twist—also hidden; player wagers an amount from the opponent's score. If correct, opponent loses that amount; if wrong, opponent gains it. Adds strategic rivalry and humor (e.g., animations of corgis "pooping" out points).
- **Theme Integration**: Corgi animations (wagging tails for correct answers, sad puppy eyes for wrong), dog puns in clues/feedback, and sound effects like barks or whimpers.
- **Win Conditions**: Highest score after Final Jeopardy! wins. Ties resolved by a sudden-death clue.

High-level architecture:
- **SpriteKit Framework**: Uses SKScenes for different screens (Main Menu, Game Board, Clue Display, Wager Screen, Final Jeopardy, End Game).
- **Data Management**: JSON files or hardcoded arrays for categories, clues, and answers. Randomize category selection to ensure 1-3 dog-themed per round.
- **UI/UX**: Touch-based interactions; animated corgi sprites using SKSpriteNode and SKActions.
- **Audio/Visuals**: Integrate simple sounds (AVAudioPlayer) and graphics (placeholder corgi images initially, replaceable with custom assets).
- **State Management**: Use a GameState model to track scores, current round, selected clues, player turns, etc.
- **Persistence**: Save high scores via UserDefaults.
- **Target Audience**: Casual gamers, dog lovers, families—aim for intuitive controls and short sessions (10-15 minutes per game).

The app starts from an existing Xcode project skeleton, so focus on adding scenes, nodes, logic, and assets. Development emphasizes modularity for easy testing and iteration.

### Engineering Spec

The spec is organized into **Epics** (high-level feature groups), each containing **Individual Tickets** (actionable tasks). Each ticket includes:
- **Description**: What to implement.
- **Acceptance Criteria**: Measurable success conditions.
- **Coding Assistant Prompt**: A detailed prompt to feed into an expert coding assistant (e.g., AI like Grok) for generating code snippets or guidance. Assume the assistant knows Swift and SpriteKit.

#### Epic 1: Game Setup and Main Menu
This epic covers initial app launch, menu navigation, and game initialization.

**Ticket 1.1: Implement Main Menu Scene**
- **Description**: Create a SpriteKit scene for the main menu with options to start a new game, select difficulty, view high scores, and exit.
- **Acceptance Criteria**:
  - Scene loads on app launch.
  - Buttons (SKNodes) for "New Game", "Difficulty" (easy/medium/hard), "High Scores", "Quit".
  - Tapping "New Game" transitions to Game Board scene.
  - Background features a corgi-themed image or animation.
  - Responsive to device orientation (portrait only for simplicity).
- **Coding Assistant Prompt**: "Write Swift code for a SpriteKit SKScene called MainMenuScene. Include SKLabelNodes or SKSpriteNodes for buttons: 'New Game', 'Difficulty' (with submenu for easy/medium/hard), 'High Scores', and 'Quit'. Handle touchesBegan to detect button taps and transition to a placeholder GameBoardScene using SKTransition. Add a background SKSpriteNode with a corgi image named 'corgi_background.png'. Ensure the scene scales properly for iPhone devices."

**Ticket 1.2: Set Up Game State Model**
- **Description**: Create a central model to manage game data like scores, rounds, players, and board state.
- **Acceptance Criteria**:
  - GameState struct/class with properties: playerScores (dictionary of player IDs to Int), currentRound (enum: jeopardy, doubleJeopardy, finalJeopardy), currentPlayerTurn (Int), board (2D array of clues with values, hidden specials).
  - Methods to reset state, update scores, advance rounds.
  - Persist high scores in UserDefaults.
  - Initialize with 1 human player and 1-2 AI opponents based on menu selection.
- **Coding Assistant Prompt**: "In Swift, define a GameState class for a Jeopardy-style game. Include properties: var playerScores: [String: Int] (e.g., 'Player1': 0, 'AI1': 0), var currentRound: RoundType (enum with cases .jeopardy, .doubleJeopardy, .finalJeopardy), var currentTurn: String, var board: [[Clue]] (Clue struct with value: Int, question: String, answer: String, isRevealed: Bool, isDailyDouble: Bool, isDailyDooDoo: Bool). Add methods: init(withPlayers: [String]), reset(), updateScore(player: String, amount: Int), nextRound(). Use UserDefaults to save/load high scores as an array of Int."

**Ticket 1.3: Integrate Player Customization**
- **Description**: Allow selecting corgi avatars for players in the menu.
- **Acceptance Criteria**:
  - Submenu in Main Menu for choosing from 3-5 corgi sprites (e.g., colors/accessories).
  - Assign avatars to human and AI players.
  - Display avatars on game screens.
  - Avatars stored in GameState.
- **Coding Assistant Prompt**: "Extend the MainMenuScene in Swift SpriteKit to include a submenu for player customization. Add SKSpriteNodes for 5 corgi avatar options (use placeholder images like 'corgi1.png' to 'corgi5.png'). On selection, store the chosen avatar in GameState's new property var playerAvatars: [String: String] (mapping player ID to image name). Ensure AI opponents get random avatars. Handle touches to select and confirm."

#### Epic 2: Game Board and Categories
This epic handles the trivia board, category generation, and clue setup.

**Ticket 2.1: Generate Categories and Clues**
- **Description**: Create logic to randomly generate 6 categories per round, with 1-3 being dog/corgi-themed, and populate with clues.
- **Acceptance Criteria**:
  - Categories stored as arrays (e.g., general: ["History", "Science"]; dog: ["Corgi Facts", "Paw-some Puns"]).
  - Randomly select and ensure 1-3 dog categories.
  - Each category has 5 clues with increasing values.
  - Clues include puns/jokes in dog categories.
  - Hide 1 Daily Double and 1 Daily Doo-Doo randomly per round (more in Double Jeopardy).
  - Data loaded from JSON or hardcoded.
- **Coding Assistant Prompt**: "In Swift, write a function generateBoard(for round: RoundType) -> [[Clue]] that creates a 6x5 board. Define Clue struct as before. Use arrays for generalCategories and dogCategories. Randomly pick 3-5 general and 1-3 dog, ensuring total 6. For each category, generate 5 clues with values (200-1000 for .jeopardy, doubled for .double). Include pun examples in dog clues, like Clue(value: 200, question: 'This corgi activity involves chasing tails.', answer: 'What is spinning?'). Randomly assign isDailyDouble and isDailyDooDoo to one clue each (two Daily Doubles in .double). Hardcode 20+ clues per category type."

**Ticket 2.2: Implement Game Board Scene**
- **Description**: Display the board as a grid of SKNodes for categories and clue values.
- **Acceptance Criteria**:
  - SKScene showing 6 category headers (SKLabelNodes) and 5x6 grid of value tiles (e.g., "$200").
  - Tapping a tile selects the clue if not revealed.
  - Revealed tiles gray out.
  - Animate corgi host introducing the board.
  - Transition to ClueScene on selection.
- **Coding Assistant Prompt**: "Create a GameBoardScene in Swift SpriteKit. Use GameState to get the board. Add SKLabelNodes for 6 category titles at the top. Below, create a 6-column, 5-row grid of SKSpriteNodes or SKLabelNodes for clue values (e.g., text: '$200'). Handle touchesBegan to detect tap on unrevealed tile, mark as revealed in GameState, and transition to ClueScene(passing selected Clue). Add an animated SKSpriteNode for the corgi host with a welcome action (e.g., SKAction.sequence for bark animation). Position everything responsively."

**Ticket 2.3: Add Round Transitions**
- **Description**: Handle advancing from Jeopardy! to Double Jeopardy! and to Final Jeopardy!.
- **Acceptance Criteria**:
  - After all clues revealed in a round, show transition screen with scores and corgi animations.
  - Generate new board for next round.
  - In Double Jeopardy!, double values and add extra Daily Double.
- **Coding Assistant Prompt**: "In GameBoardScene, add logic to check if all clues are revealed (iterate GameState.board). If yes, present a TransitionScene with current scores displayed via SKLabelNodes and corgi animations (e.g., happy dance SKAction). After delay, call GameState.nextRound(), regenerate board, and reload GameBoardScene or transition to FinalJeopardyScene if applicable. Ensure Double Jeopardy has doubled values and two Daily Doubles."

#### Epic 3: Clue Selection and Answering
This epic covers presenting clues, buzzing, and answering.

**Ticket 3.1: Implement Clue Display Scene**
- **Description**: Show the selected clue text and allow buzzing/answering.
- **Acceptance Criteria**:
  - Display clue as SKLabelNode.
  - Simulate buzzing: Tap screen to "buzz in" (AI buzzes with delay based on difficulty).
  - First to buzz gets to answer via text input or multiple choice (for simplicity, use text input).
  - Check answer (case-insensitive, must start with "What is" or similar).
  - Update scores and return to board.
  - Corgi animations for correct/wrong (e.g., tail wag or whimper).
- **Coding Assistant Prompt**: "Write ClueScene in Swift SpriteKit. Init with Clue object. Display clue.question in large SKLabelNode. Add a 'Buzz In' SKButton (or full-screen tap). For AI, use Timer to simulate buzz delay (1-3s based on difficulty). On buzz, present UITextField for answer input. Validate if answer.lowercased() contains clue.answer.lowercased() and starts with 'what is' or 'who is'. Update GameState scores (+/- value). Add SKActions for corgi avatar reactions (e.g., jump for correct). Transition back to GameBoardScene."

**Ticket 3.2: Handle AI Opponent Logic**
- **Description**: Implement AI behavior for buzzing and answering.
- **Acceptance Criteria**:
  - AI buzzes with variable speed/accuracy (easy: 50% correct, slow; hard: 90% correct, fast).
  - AI "answers" randomly correct/wrong.
  - Display AI answers as labels.
- **Coding Assistant Prompt**: "In ClueScene, add AI logic. For each AI player, schedule a Timer (delay: easy=3s, medium=2s, hard=1s). If AI buzzes first, generate answer: Bool correct = (difficulty-based probability). If correct, show 'What is [answer]?' label and add score; else wrong answer and subtract. Ensure human can buzz faster. Use GameState.currentTurn to rotate if no buzz."

#### Epic 4: Special Features - Daily Double and Daily Doo-Doo
This epic implements wagering specials.

**Ticket 4.1: Implement Daily Double**
- **Description**: On selecting a Daily Double, show wager screen and handle outcome.
- **Acceptance Criteria**:
  - Transition to WagerScene where player inputs wager (0 to current score).
  - Then show clue, answer, update score based on correct/wrong.
  - Only current player wagers their own score.
- **Coding Assistant Prompt**: "Create WagerScene for Daily Double. Display 'Daily Double! Wager up to your score: $\(GameState.playerScores[currentTurn]!)'. Use UITextField for input, validate 0...max. Store wager, then transition to ClueScene with isWager=true. In ClueScene, if correct add wager, else subtract. Add corgi sound effect for reveal."

**Ticket 4.2: Implement Daily Doo-Doo**
- **Description**: Similar to Daily Double, but wager affects opponent's score.
- **Acceptance Criteria**:
  - Wager 0 to opponent's current score.
  - If correct, subtract from opponent; wrong, add to opponent.
  - Humorous animation (e.g., poo emoji or corgi "doo-doo" sprite).
  - Opponent selected if multiple (e.g., lowest/highest score).
- **Coding Assistant Prompt**: "Extend WagerScene for Daily Doo-Doo. Prompt 'Daily Doo-Doo! Wager opponent's score: $\(opponentScore)'. Validate input. In ClueScene, if correct: GameState.updateScore(opponent, -wager); else +wager. Add fun SKAction: animate a 'poo' SKSpriteNode flying to/from opponent avatar. Assume single opponent for simplicity; extend for multiple."

#### Epic 5: Final Jeopardy and End Game
This epic wraps up the game.

**Ticket 5.1: Implement Final Jeopardy Scene**
- **Description**: All players wager secretly, see clue, answer, reveal scores.
- **Acceptance Criteria**:
  - Each player (human via input, AI random) wagers 0 to their score.
  - Display category, then clue.
  - Time-limited answers (30s timer).
  - Reveal answers and adjust scores.
  - Declare winner with corgi celebration.
- **Coding Assistant Prompt**: "Create FinalJeopardyScene. Sequence: 1. Wager phase: UITextField for human, AI random 50-100% of score. 2. Show category SKLabel. 3. Reveal clue after all wagers. 4. Answer input with 30s SKLabel countdown Timer. 5. Validate answers. 6. Update scores: correct +wager, wrong -wager. 7. Show winner with confetti SKParticle and corgi dance animation."

**Ticket 5.2: End Game and High Scores**
- **Description**: Show end screen with scores, save high score, return to menu.
- **Acceptance Criteria**:
  - Display final scores and winner.
  - If human wins, save score if higher than previous.
  - Button to restart or menu.
- **Coding Assistant Prompt**: "After FinalJeopardy, transition to EndGameScene. Display SKLabels for scores and 'Winner: [player]!'. If human score > UserDefaults highScore, update. Add buttons for 'Play Again' (reset GameState, to GameBoard) and 'Menu' (to MainMenuScene). Include victory corgi sprites."

#### Epic 6: Graphics, Animations, and Polish
This epic adds theme and UX enhancements.

**Ticket 6.1: Add Corgi Animations and Sounds**
- **Description**: Integrate sprite animations and audio for key events.
- **Acceptance Criteria**:
  - Corgi sprites animate on correct/wrong, wagers, etc.
  - Sounds: bark for correct, whimper for wrong (using AVAudioPlayer).
  - All scenes have consistent theme.
- **Coding Assistant Prompt**: "In relevant scenes (e.g., ClueScene, WagerScene), add SKSpriteNode for corgi with texture atlases for animations (e.g., SKAction.animate(with: textures, timePerFrame: 0.1) for tail wag). Import AVFoundation, create AVAudioPlayer for 'bark.mp3' and 'whimper.mp3'. Play on correct/wrong. Provide code snippets for integration."

**Ticket 6.2: Testing and Bug Fixes**
- **Description**: Set up basic unit tests and handle edge cases.
- **Acceptance Criteria**:
  - Tests for score updates, board generation, answer validation.
  - Handle negative scores, zero wagers, invalid inputs.
  - App runs without crashes on simulator.
- **Coding Assistant Prompt**: "Write XCTest cases in Swift for GameState: testUpdateScore(), testGenerateBoard(ensures 1-3 dog categories), testAnswerValidation(). Include edge cases like wager > score (clamp), negative scores (allow, as in Jeopardy). Suggest debugging tips for SpriteKit touches and transitions."
