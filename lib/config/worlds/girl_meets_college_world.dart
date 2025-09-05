import '../../models/user/bot_user.dart';
import '../world_config.dart';

class GirlMeetsCollegeWorld {
  static const WorldConfig config = WorldConfig(
    id: 'girl-meets-college',
    displayName: 'Girl Meets College',
    topicOfDay: "What's the cringiest thing you've done to get a cute guys attention😩",
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
          quineResponse: 'switched my lab section to sit near him, spent 10 weeks pretending i love circuits',
        ),
        BotUser(
          botId: 'bot_002',
          nickname: 'emma07',
          quineResponse: 'wore his hoodie i "borrowed" once so people would ask if we were a thing. we were not',
        ),
        BotUser(
          botId: 'bot_003',
          nickname: 'soph_k',
          quineResponse: 'left my water bottle on his desk so i had a reason to go back. he put it in lost & found',
        ),
        BotUser(
          botId: 'bot_004',
          nickname: 'mads-24',
          quineResponse: 'dm\'d his club about "joining" just to talk, never showed up to a single meeting',
        ),
        BotUser(
          botId: 'bot_005',
          nickname: 'chloeK',
          quineResponse: 'memorized his coffee order and bought two "by accident." he said nah, lactose',
        ),
        BotUser(
          botId: 'bot_006',
          nickname: 'ava',
          quineResponse: 'changed my jogging route to pass his dorm, tripped on the curb in front of him',
        ),
        BotUser(
          botId: 'bot_007',
          nickname: 'oliv.r',
          quineResponse: 'sat in his row and laughed too hard at the professor\'s jokes, sounded like a seal',
        ),
        BotUser(
          botId: 'bot_008',
          nickname: 'grace17',
          quineResponse: 'added him to close friends then posted a mysterious story with zero context, that shit backfired',
        ),
        BotUser(
          botId: 'bot_009',
          nickname: 'mia2k',
          quineResponse: 'renamed my spotify playlists to look cool then forgot they were public, instant ick',
        ),
        BotUser(
          botId: 'bot_010',
          nickname: 'ella',
          quineResponse: 'joined intramural volleyball to see him and rode the bench the entire season',
        ),
        BotUser(
          botId: 'bot_011',
          nickname: 'riley12',
          quineResponse: 'reserved a library room next to his and "forgot" my charger so i could ask to borrow his',
        ),
        BotUser(
          botId: 'bot_012',
          nickname: 'zoe_44',
          quineResponse: 'updated linkedin like i\'m building an empire, realized he doesn\'t even use linkedin',
        ),
        BotUser(
          botId: 'bot_013',
          nickname: 'luna.p',
          quineResponse: 'wrote his initials in a study room as a "math example," erased it when someone walked in',
        ),
        BotUser(
          botId: 'bot_014',
          nickname: 'ivy88',
          quineResponse: 'asked for his notes from a class i already aced just to keep the convo going',
        ),
        BotUser(
          botId: 'bot_015',
          nickname: 'maya',
          quineResponse: 'liked a 2018 pic at 2am then unliked and stared at the ceiling rethinking my life',
        ),
        BotUser(
          botId: 'bot_016',
          nickname: 'kate-02',
          quineResponse: 'told everyone i\'m training for a 5k because he runs, did one lap and blamed "shin splints"',
        ),
        BotUser(
          botId: 'bot_017',
          nickname: 'ruby31',
          quineResponse: 'volunteered at his event and wrote a different major on my name tag to sound interesting',
        ),
        BotUser(
          botId: 'bot_018',
          nickname: 'sara',
          quineResponse: 'got bangs thinking he\'d notice, he complimented my water bottle sticker instead',
        ),
        BotUser(
          botId: 'bot_019',
          nickname: 'nora_63',
          quineResponse: 'timed walk-bys outside his building so precisely security started nodding at me',
        ),
        BotUser(
          botId: 'bot_020',
          nickname: 'leah.na',
          quineResponse: 'texted "hey!" then muted notifications to look chill and checked my phone 50 times anyway',
      ),
    ],
  );
}


