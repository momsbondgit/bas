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
      BotUser(
        botId: 'chaos_g6',
        nickname: 'drama.alert',
        quineResponse: 'the way this just escalated 👀 living for the chaos',
        goodbyeText: 'drama documented, exiting stage left 🎭',
      ),
      BotUser(
        botId: 'chaos_g7',
        nickname: 'unhinged.bestie',
        quineResponse: 'girl the audacity... i stan tho 💀',
        goodbyeText: 'unhinged energy depleted, bye loves 💀',
      ),
      BotUser(
        botId: 'chaos_g8',
        nickname: 'messy.queen',
        quineResponse: 'this is so messy i love it 🍿 keep going',
        goodbyeText: 'mess acknowledged, queen out 👑',
      ),
      BotUser(
        botId: 'chaos_g9',
        nickname: 'savage.mode',
        quineResponse: 'the way u just ended them 😭 brutal bestie',
        goodbyeText: 'savage mode deactivated, ttyl 😈',
      ),
      BotUser(
        botId: 'chaos_g10',
        nickname: 'chaos.goblin',
        quineResponse: 'we\'re all going to hell for laughing at this 🔥',
        goodbyeText: 'chaos achieved, goblin retreating 👹',
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
      BotUser(
        botId: 'goofy_g6',
        nickname: 'wholesome.bean',
        quineResponse: 'this is so valid bestie 🥺 we support u',
        goodbyeText: 'bye loves, stay wholesome 🌸💕',
      ),
      BotUser(
        botId: 'goofy_g7',
        nickname: 'emotional.support',
        quineResponse: 'bestie ur so brave for sharing this 💗',
        goodbyeText: 'emotional support signing off, love u all 💗',
      ),
      BotUser(
        botId: 'goofy_g8',
        nickname: 'baby.energy',
        quineResponse: 'this is giving me life omg 🥰 ur amazing',
        goodbyeText: 'baby energy depleted, nap time bye 🥰',
      ),
      BotUser(
        botId: 'goofy_g9',
        nickname: 'pure.vibes',
        quineResponse: 'the way this made my day better 🌟 thank u bestie',
        goodbyeText: 'pure vibes only, see u later loves 🌟',
      ),
      BotUser(
        botId: 'goofy_g10',
        nickname: 'soft.clown',
        quineResponse: 'why is this literally me tho 🤡💕 felt that',
        goodbyeText: 'clown car leaving, honk honk 🤡💕',
      ),
    ],
  );
}

