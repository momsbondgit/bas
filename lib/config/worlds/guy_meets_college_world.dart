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
      BotUser(
        botId: 'chaos_m6',
        nickname: 'menace.energy',
        quineResponse: 'bro woke up and chose violence 💀 i respect it',
        goodbyeText: 'menace mode off, peace out kings 💀',
      ),
      BotUser(
        botId: 'chaos_m7',
        nickname: 'toxic.king',
        quineResponse: 'this is foul but im here for it 😈',
        goodbyeText: 'toxic energy depleted, later bros 😈',
      ),
      BotUser(
        botId: 'chaos_m8',
        nickname: 'unhinged.bro',
        quineResponse: 'nah the audacity 😭 but facts tho',
        goodbyeText: 'unhinged session over, deuces 😭',
      ),
      BotUser(
        botId: 'chaos_m9',
        nickname: 'demon.time',
        quineResponse: 'bro really said that with his whole chest 🔥',
        goodbyeText: 'demon time over, back to normal 🔥',
      ),
      BotUser(
        botId: 'chaos_m10',
        nickname: 'chaos.agent',
        quineResponse: 'we all going to hell for laughing at this 💀',
        goodbyeText: 'chaos mission complete, agent out 💀',
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
      BotUser(
        botId: 'goofy_m6',
        nickname: 'golden.boy',
        quineResponse: 'this is so valid king 🙏 we support u',
        goodbyeText: 'golden boy signing off, stay blessed 🙏',
      ),
      BotUser(
        botId: 'goofy_m7',
        nickname: 'soft.hours',
        quineResponse: 'bro ur so real for this 💯 respect',
        goodbyeText: 'soft hours over, catch y\'all later 💯',
      ),
      BotUser(
        botId: 'goofy_m8',
        nickname: 'himbo.energy',
        quineResponse: 'this is fire bro!! 🔥 ur killing it',
        goodbyeText: 'himbo out, keep being amazing bros 🔥',
      ),
      BotUser(
        botId: 'goofy_m9',
        nickname: 'pure.king',
        quineResponse: 'the way this made my day better 💪 thanks bro',
        goodbyeText: 'pure king departing, stay real bros 💪',
      ),
      BotUser(
        botId: 'goofy_m10',
        nickname: 'goofy.goober',
        quineResponse: 'why is this literally me tho 🤡 felt that',
        goodbyeText: 'goofy goober rolling out, honk honk 🤡',
      ),
    ],
  );
}
