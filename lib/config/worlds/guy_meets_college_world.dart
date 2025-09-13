import '../../models/user/bot_user.dart';
import '../world_config.dart';

class GuyMeetsCollegeWorld {
  static const WorldConfig config = WorldConfig(
    id: 'guy-meets-college',
    displayName: 'Guy Meets College',
    topicOfDay: "funniest L u or them took during sex 😭😭",
    modalTitle: 'No code, no access. Only members can invite.',
    modalDescription: null,
    entryTileImage: 'assets/images/guy_meets_college.png', // TODO: Add actual asset path
    vibeSection: '',
    headingText: 'bro topic of the day',
    backgroundColorHue: 220, // Deep blue hue for guy energy
    characterLimit: 180, // Reduced limit
    // Table 1: Chaotic/Edgy personalities for Guy Meets College
    botTable1: [
      BotUser(
        botId: 'chaos_m1',
        nickname: 'chaos.king',
        quineResponse: 'bruh said what needed to be said 💀 respect the honesty',
        goodbyeText: 'alright bros, chaos king out 👑💀',
      ),
      BotUser(
        botId: 'chaos_m2',
        nickname: 'no.chill',
        quineResponse: 'straight violation 😭 but someone had to say it fr',
        goodbyeText: 'peace y\'all, been unhinged as usual 😭',
      ),
      BotUser(
        botId: 'chaos_m3',
        nickname: 'savage.mode',
        quineResponse: 'nah this is wild 💀 u really did that',
        goodbyeText: 'savage mode deactivated, later bros 💀',
      ),
      BotUser(
        botId: 'chaos_m4',
        nickname: 'villain.szn',
        quineResponse: 'choosing chaos today i see 😈 here for it',
        goodbyeText: 'villain season complete, catch y\'all 😈',
      ),
      BotUser(
        botId: 'chaos_m5',
        nickname: 'zero.filter',
        quineResponse: 'said what we all thinking 🔥 no holds barred',
        goodbyeText: 'unfiltered exit, been real bros 🔥',
      ),
    ],

    // Table 2: Goofy/Soft personalities for Guy Meets College
    botTable2: [
      BotUser(
        botId: 'goofy_m1',
        nickname: 'wholesome.bro',
        quineResponse: 'aw man this got me in my feels 🥺 sending support',
        goodbyeText: 'peace bros, sending good vibes 🥺🙏',
      ),
      BotUser(
        botId: 'goofy_m2',
        nickname: 'hype.man',
        quineResponse: 'YOOO this energy!! love this for u king 💪',
        goodbyeText: 'YOOO later kings!! stay legendary!! 💪🔥',
      ),
      BotUser(
        botId: 'goofy_m3',
        nickname: 'awkward.king',
        quineResponse: 'lmaooo bro same 😭 why we like this',
        goodbyeText: 'bye bros, hope that wasn\'t too weird lmao 😭',
      ),
      BotUser(
        botId: 'goofy_m4',
        nickname: 'good.vibes',
        quineResponse: 'hope u good bro 🤝 always got ur back',
        goodbyeText: 'later bros, always got y\'all backs 🤝',
      ),
      BotUser(
        botId: 'goofy_m5',
        nickname: 'smooth.brain',
        quineResponse: 'wait huh 🤔 sorry wasnt listening lol',
        goodbyeText: 'bye bros, wait what are we doing again? 🤔',
      ),
    ],

    // Table 3: Balanced/Mixed personalities for Guy Meets College
    botTable3: [
      BotUser(
        botId: 'mixed_m1',
        nickname: 'balanced.bro',
        quineResponse: 'yeah bro i feel u 💭 this is pretty valid ngl',
        goodbyeText: 'peace bros, balanced exit as always ✨',
      ),
      BotUser(
        botId: 'mixed_m2',
        nickname: 'vibe.shift',
        quineResponse: 'mood honestly 🤷‍♂️ we got layers bro',
        goodbyeText: 'shifting to goodbye vibe, later bros 🤷‍♂️',
      ),
      BotUser(
        botId: 'mixed_m3',
        nickname: 'chaotic.good',
        quineResponse: 'love the energy king 🌟 but also kinda sus lmao',
        goodbyeText: 'chaotic good logging off, peace kings 🌟',
      ),
      BotUser(
        botId: 'mixed_m4',
        nickname: 'soft.chaos',
        quineResponse: 'bro ur real for this 💫 gentle but make it wild',
        goodbyeText: 'soft chaos complete, later bros 💫',
      ),
      BotUser(
        botId: 'mixed_m5',
        nickname: 'complex.king',
        quineResponse: 'this hits different ✨ complicated but respect',
        goodbyeText: 'complex king out, been real bros 👑✨',
      ),
    ],
  );
}
