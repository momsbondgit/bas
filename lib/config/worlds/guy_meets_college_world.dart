import '../../models/user/bot_user.dart';
import '../world_config.dart';

class GuyMeetsCollegeWorld {
  static const WorldConfig config = WorldConfig(
    id: 'guy-meets-college',
    displayName: 'Guy Meets College',
    topicOfDay: "What's the dumbest thing you've done to impress a girl😅",
    modalTitle: 'No code, no access. Only members can invite.',
    modalDescription: null,
    entryTileImage: 'assets/images/guy_meets_college.png', // TODO: Add actual asset path
    vibeSection: '',
    headingText: 'bro topic of the day',
    backgroundColorHue: 220, // Deep blue hue for guy energy
    botPool: [
        BotUser(
          botId: 'bot_m021',
          nickname: 'softly',
          quineResponse: 'did 50 pushups before lecture so i\'d look pumped. walked in shaking like a chihuahua',
        ),
        BotUser(
          botId: 'bot_m022',
          nickname: 'willow_17',
          quineResponse: 'wrote a poem that rhymed heart with apart eight times and thought it was bars',
        ),
        BotUser(
          botId: 'bot_m023',
          nickname: 'lofi',
          quineResponse: 'made a playlist called "for us" then she asked who "us" was',
        ),
        BotUser(
          botId: 'bot_m024',
          nickname: 'eastside3',
          quineResponse: 'asked her fav coffee then ordered it black and almost met god',
        ),
        BotUser(
          botId: 'bot_m025',
          nickname: 'oddjob',
          quineResponse: 'wore rings for one day. fingers turned green. aria said i looked like loki on a budget',
        ),
        BotUser(
          botId: 'bot_m026',
          nickname: 'midterm04',
          quineResponse: 'posted a gym selfie caption "locked in." forgot leg day for 3 months',
        ),
        BotUser(
          botId: 'bot_m027',
          nickname: 'pebble',
          quineResponse: 'learned three chords and tried to freestyle her name. name has five syllables',
        ),
        BotUser(
          botId: 'bot_m028',
          nickname: 'afterhours',
          quineResponse: 'told the barber "give me riz." he handed me a beanie',
        ),
        BotUser(
          botId: 'bot_m029',
          nickname: 'sidestep',
          quineResponse: 'stood outside her dorm "accidentally" four times. RA knows my schedule now',
        ),
        BotUser(
          botId: 'bot_m030',
          nickname: 'tman97',
          quineResponse: 'invited her to a party i wasn\'t actually invited to',
        ),
        BotUser(
          botId: 'bot_m031',
          nickname: 'blink',
          quineResponse: 'asked to study then stared at the same google doc for 90 minutes',
        ),
        BotUser(
          botId: 'bot_m032',
          nickname: 'gluestick',
          quineResponse: 'bought a candle called moss & teak. room smelled like home depot',
        ),
        BotUser(
          botId: 'bot_m033',
          nickname: 'jaykay',
          quineResponse: 'tried a wink. both eyes closed. looked like i passed out',
        ),
        BotUser(
          botId: 'bot_m034',
          nickname: 'overcast',
          quineResponse: 'learned a british accent for two days. sounded australian, got booed',
        ),
        BotUser(
          botId: 'bot_m035',
          nickname: 'solo',
          quineResponse: 'saved her contact as future wife then airplayed my screen in class',
        ),
        BotUser(
          botId: 'bot_m036',
          nickname: 'murmur',
          quineResponse: 'asked her sign then mixed up libra with libra... somehow wrong both times',
        ),
        BotUser(
          botId: 'bot_m037',
          nickname: 'plainbagel',
          quineResponse: 'bought matching bracelets for "us." i was the only one wearing one',
        ),
        BotUser(
          botId: 'bot_m038',
          nickname: 'quiet_mode',
          quineResponse: 'sent a voice note. played it back. deleted my personality for 24 hours',
        ),
        BotUser(
          botId: 'bot_m039',
          nickname: 'sevenways',
          quineResponse: 'made latte art to impress her. it looked like ohio',
        ),
        BotUser(
          botId: 'bot_m040',
          nickname: 'detour',
          quineResponse: 'wore a turtleneck to a house party. sweated out my dignity',
        ),
        BotUser(
          botId: 'bot_m061',
          nickname: 'clover',
          quineResponse: 'practiced my smile on front cam, looked like i bit a lemon, posted it anyway',
        ),
        BotUser(
          botId: 'bot_m062',
          nickname: 'apt_3b',
          quineResponse: 'opened with a knock knock joke, she said wrong door, i\'m cooked',
        ),
        BotUser(
          botId: 'bot_m063',
          nickname: 'neon',
          quineResponse: 'played spikeball to impress her, spiked it into my own face',
        ),
        BotUser(
          botId: 'bot_m064',
          nickname: 'couchshift',
          quineResponse: 'told her to come thru, roommate had six dudes screaming at fifa, vibes dead',
        ),
        BotUser(
          botId: 'bot_m065',
          nickname: 'pocket',
          quineResponse: 'bought a thrifted leather jacket, smelled like a basement, still wore it',
        ),
        BotUser(
          botId: 'bot_m066',
          nickname: 'thursday11',
          quineResponse: 'took her to a hidden gem taco spot, closed on monday, stood there like an npc',
      ),
    ],
  );
}