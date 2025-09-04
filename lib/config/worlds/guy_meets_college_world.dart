import '../../models/bot_user.dart';
import '../world_config.dart';

class GuyMeetsCollegeWorld {
  static const WorldConfig config = WorldConfig(
    id: 'guy-meets-college',
    displayName: 'Guy Meets College',
    topicOfDay: "What's the dumbest thing you've done to impress a girl😅",
    modalTitle: 'join the world bro ✨',
    modalDescription: 'Share your college confession with other guys anonymously. Get access code from your community.',
    entryTileImage: 'assets/images/guy_meets_college.png', // TODO: Add actual asset path
    vibeSection: 'The vibe is peak bro energy with a side of actual vulnerability. We\'re talking about those moments when you tried way too hard and it backfired spectacularly. No judgment here - just guys being real about their most questionable decisions.',
    headingText: 'bro topic of the day',
    backgroundColorHue: 120, // Green hue for guy energy
    botPool: [
      BotUser(
        botId: 'bot_m001',
        nickname: 'alex',
        quineResponse: 'I spent my entire paycheck on a gym membership just because my crush said she likes fit guys, haven\'t been once 💀',
      ),
      BotUser(
        botId: 'bot_m002', 
        nickname: 'jake',
        quineResponse: 'I\'ve been wearing the same lucky shirt to every party for three weeks because I think it makes me look cool',
      ),
      BotUser(
        botId: 'bot_m003',
        nickname: 'tyler',
        quineResponse: 'My roommate thinks I\'m studying but I\'ve been playing FIFA for 6 hours straight',
      ),
      BotUser(
        botId: 'bot_m004',
        nickname: 'connor',
        quineResponse: 'I told everyone I was busy but really I just wanted to stay in and watch Netflix',
      ),
      BotUser(
        botId: 'bot_m005',
        nickname: 'mason',
        quineResponse: 'I have a crush on the girl from my econ class and I sit in the same spot hoping she\'ll notice me',
      ),
      BotUser(
        botId: 'bot_m006',
        nickname: 'noah',
        quineResponse: 'I accidentally said \'love you\' instead of \'thank you\' to the cashier at the dining hall',
      ),
      BotUser(
        botId: 'bot_m007',
        nickname: 'ethan',
        quineResponse: 'I\'ve been eating ramen every night because I spent all my food money on concert tickets',
      ),
      BotUser(
        botId: 'bot_m008',
        nickname: 'lucas',
        quineResponse: 'I pretend to know about sports when talking to girls but I literally only watch highlights on Instagram',
      ),
      BotUser(
        botId: 'bot_m009',
        nickname: 'ryan',
        quineResponse: 'I still call my mom to ask her how to do laundry and I\'m a junior',
      ),
      BotUser(
        botId: 'bot_m010',
        nickname: 'carter',
        quineResponse: 'I\'ve been avoiding this girl for two weeks because I sent her a text meant for my mom',
      ),
      BotUser(
        botId: 'bot_m011',
        nickname: 'owen',
        quineResponse: 'I told my parents I\'m getting straight A\'s but I\'m actually failing calc and haven\'t told anyone',
      ),
      BotUser(
        botId: 'bot_m012',
        nickname: 'hunter',
        quineResponse: 'I\'ve been using the same towel for three weeks because I keep forgetting to do laundry',
      ),
      BotUser(
        botId: 'bot_m013',
        nickname: 'blake',
        quineResponse: 'I cried watching a Disney movie last night and I\'m not telling my roommates which one',
      ),
      BotUser(
        botId: 'bot_m014',
        nickname: 'jordan',
        quineResponse: 'I have no idea how to cook anything except mac and cheese and I eat it every day',
      ),
      BotUser(
        botId: 'bot_m015',
        nickname: 'austin',
        quineResponse: 'I screenshot texts from girls and send them to the group chat asking what they mean',
      ),
      BotUser(
        botId: 'bot_m016',
        nickname: 'logan',
        quineResponse: 'I\'ve been wearing the same pair of jeans for a week because they\'re my only clean ones',
      ),
      BotUser(
        botId: 'bot_m017',
        nickname: 'cole',
        quineResponse: 'I laugh at everything my professor says even when it\'s not funny because I need the grade',
      ),
      BotUser(
        botId: 'bot_m018',
        nickname: 'drew',
        quineResponse: 'I still have my mom schedule all my appointments because adulting is scary',
      ),
      BotUser(
        botId: 'bot_m019',
        nickname: 'kyle',
        quineResponse: 'I\'ve been lying about knowing how to change a tire because I thought it would impress people',
      ),
      BotUser(
        botId: 'bot_m020',
        nickname: 'chase',
        quineResponse: 'I eat in my dorm room instead of the dining hall because social anxiety is real',
      ),
    ],
  );
}