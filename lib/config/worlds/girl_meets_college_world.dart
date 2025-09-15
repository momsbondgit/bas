import '../../models/user/bot_user.dart';
import '../world_config.dart';

class GirlMeetsCollegeWorld {
  static const WorldConfig config = WorldConfig(
    id: 'girl-meets-college',
    displayName: 'Girl Meets College',
    topicOfDay: "ok… what's the weirdest or most annoying thing u seen in Lions Gate so far 👀💀",
    modalTitle: 'No code, no access. Only members can invite.',
    modalDescription: null,
    entryTileImage: 'assets/images/girl_meets_college.png', // TODO: Add actual asset path
    vibeSection: '',
    headingText: 'tea topic of the day',
    backgroundColorHue: 340, // Pink/rose hue for girl energy
    characterLimit: 180, // Reduced limit
    // Table 1: Chaotic/Edgy personalities for Girl Meets College (hype table)
    botTable1: [
      BotUser(
        botId: 'chaos_g1',
        nickname: 'chaos.queen',
        quineResponse: 'periodt queen 💅 spill that tea sis',
        goodbyeText: 'bye besties, stay iconic 💅✨',
      ),
      BotUser(
        botId: 'chaos_g2',
        nickname: 'spicy.takes',
        quineResponse: 'not u being controversial again 💀 here for it tho',
        goodbyeText: 'alright bestie, that\'s my cue to leave 🚪',
      ),
      BotUser(
        botId: 'chaos_g3',
        nickname: 'no.filter',
        quineResponse: 'bestie said what we all thinking 🔥 no cap',
        goodbyeText: 'bye babes, no cap this was fun 🔥',
      ),
      BotUser(
        botId: 'chaos_g4',
        nickname: 'villain.era',
        quineResponse: 'choosing violence today i see 😈 respect',
        goodbyeText: 'villain era complete, peace out 😈',
      ),
      BotUser(
        botId: 'chaos_g5',
        nickname: 'toxic.trait',
        quineResponse: 'this is giving main character energy 💯 obsessed',
        goodbyeText: 'main character exit, as expected 💅',
      ),
    ],

    // Table 2: Goofy/Soft personalities for Girl Meets College (chill table)
    botTable2: [
      BotUser(
        botId: 'goofy_g1',
        nickname: 'soft.hours',
        quineResponse: 'aw this made me smile 🥺💕 sending virtual hugs',
        goodbyeText: 'bye besties, sending love always 💕🥺',
      ),
      BotUser(
        botId: 'goofy_g2',
        nickname: 'golden.retriever',
        quineResponse: 'YES!! this energy!! love this for u bestie ✨',
        goodbyeText: 'bye besties!! this was amazing!! ✨💕',
      ),
      BotUser(
        botId: 'goofy_g3',
        nickname: 'anxious.bestie',
        quineResponse: 'lmao me fr 😭 why are we like this bestie',
        goodbyeText: 'bye besties, hope I wasn\'t too weird 😭💕',
      ),
      BotUser(
        botId: 'goofy_g4',
        nickname: 'comfort.character',
        quineResponse: 'hope ur doing okay babe 🤗 proud of u always',
        goodbyeText: 'bye besties, so proud of you all 🤗💕',
      ),
      BotUser(
        botId: 'goofy_g5',
        nickname: 'no.thoughts',
        quineResponse: 'wait what 🤔 sorry i wasnt paying attention lol',
        goodbyeText: 'bye besties, wait what happened? 🤔',
      ),
    ],
  );
}

