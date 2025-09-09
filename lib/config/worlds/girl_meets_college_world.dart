import '../../models/user/bot_user.dart';
import '../world_config.dart';

class GirlMeetsCollegeWorld {
  static const WorldConfig config = WorldConfig(
    id: 'girl-meets-college',
    displayName: 'Girl Meets College',
    topicOfDay: "What's the cringiest thing you've done to get a cute guy's attention 😩",
    modalTitle: 'No code, no access. Only members can invite.',
    modalDescription: null,
    entryTileImage: 'assets/images/girl_meets_college.png', // TODO: Add actual asset path
    vibeSection: '',
    headingText: 'tea topic of the day',
    backgroundColorHue: 340, // Pink/rose hue for girl energy
    botPool: [
      BotUser(
        botId: 'bot_001',
        nickname: 'liz',
        quineResponse: 'switched my whole lab just to sit near him… man DROPPED the class after 2 weeks 🤡',
      ),
      BotUser(
        botId: 'bot_002',
        nickname: 'emma07',
        quineResponse: 'wore his hoodie i “borrowed” so ppl would ask if we were a thing 🥹',
      ),
      BotUser(
        botId: 'bot_003',
        nickname: 'soph_k',
        quineResponse: 'left my water bottle on his desk so id “have to go back” … he threw it out 😭',
      ),
      BotUser(
        botId: 'bot_004',
        nickname: 'mads-24',
        quineResponse: 'sat in lares fake studying for 2 hrs waiting for him to walk in… never showed up 💀',
      ),
      BotUser(
        botId: 'bot_005',
        nickname: 'chloeK',
        quineResponse: 'dropped my pen like 6 times on purpose… bro didn\'t even look at me, just passed it back',
      ),
      BotUser(
        botId: 'bot_006',
        nickname: 'ava',
        quineResponse: 'moved seats to sit next to him… he asked if i could move cuz he couldn\'t see the board 💀',
      ),
      BotUser(
        botId: 'bot_007',
        nickname: 'oliv.r',
        quineResponse: 'joined the gym same time as him, ran 3 mins and almost passed out lmao',
      ),
      BotUser(
        botId: 'bot_008',
        nickname: 'grace17',
        quineResponse: 'walked the LONG way to class just to “accidentally” pass him… late 4 days in a row and still no boo',
      ),
      BotUser(
        botId: 'bot_009',
        nickname: 'mia2k',
        quineResponse: 'laughed way too hard at his comment in class… whole lecture hall looked at me like girl chill 😭',
      ),
      BotUser(
        botId: 'bot_010',
        nickname: 'ella',
        quineResponse: 'study sesh in the library he\'s locked in, i\'m staring at his reflection in my screen 😩',
      ),
      BotUser(
        botId: 'bot_011',
        nickname: 'riley12',
        quineResponse: 'kept walking by his table in lares like i needed napkins… came back w 7 stacks',
      ),
      BotUser(
        botId: 'bot_012',
        nickname: 'zoe_44',
        quineResponse: 'timed my water refill w his in lares… panicked n said “yo whats good dude” 🤦‍♀️',
      ),
      BotUser(
        botId: 'bot_013',
        nickname: 'luna.p',
        quineResponse: 'he invited me to “study” in his room… tripped over laundry and ate FLOOR before i sat down',
      ),
      BotUser(
        botId: 'bot_014',
        nickname: 'ivy88',
        quineResponse: 'asked for his notes in a class i already ACED just so i had a reason to text him',
      ),
      BotUser(
        botId: 'bot_015',
        nickname: 'maya',
        quineResponse: 'liked his 2018 insta post at 2am then unliked, stared at the ceiling rethinking life',
      ),
      BotUser(
        botId: 'bot_016',
        nickname: 'kate-02',
        quineResponse: 'got invited to his dorm, tried to sit cute on his bed… that shit was HIGH i had to climb like a toddler',
      ),
      BotUser(
        botId: 'bot_017',
        nickname: 'ruby31',
        quineResponse: 'pulled up to his dorm, sat on his bed n his roommate goes “damn she\'s brave” 😭😭',
      ),
      BotUser(
        botId: 'bot_018',
        nickname: 'sara',
        quineResponse: 'pretended to know the lyrics to his fav song… was mumbling straight nonsense the whole time',
      ),
      BotUser(
        botId: 'bot_019',
        nickname: 'nora_63',
        quineResponse: 'tried walking next to him after lecture, tripped on the stairs… he just kept going 🫠',
      ),
      BotUser(
        botId: 'bot_020',
        nickname: 'leah.na',
        quineResponse: 'texted “hey!!” then muted notifs so i\'d look chill… checked my phone 50 times anyway',
      ),
    ],
  );
}
