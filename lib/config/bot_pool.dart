import 'dart:math';
import '../models/user/bot_user.dart';

class BotPool {
  static const List<BotUser> allBots = [
    BotUser(
      botId: 'bot_001',
      nickname: 'liz',
      quineResponse: 'Okay so I literally pretended to drop my pencil in calc just to pick it up near his desk and he didn\'t even notice 😭',
    ),
    BotUser(
      botId: 'bot_002', 
      nickname: 'emma',
      quineResponse: 'I have been wearing the same hoodie for three days straight and I\'m not even sorry about it',
    ),
    BotUser(
      botId: 'bot_003',
      nickname: 'sophie',
      quineResponse: 'My roommate thinks I\'m studying but I\'ve been watching TikToks for 2 hours straight',
    ),
    BotUser(
      botId: 'bot_004',
      nickname: 'madison',
      quineResponse: 'I told everyone I was sick but really I just didn\'t want to go to that party',
    ),
    BotUser(
      botId: 'bot_005',
      nickname: 'chloe',
      quineResponse: 'I have a crush on the barista at the coffee shop and I go there way too often now',
    ),
    BotUser(
      botId: 'bot_006',
      nickname: 'ava',
      quineResponse: 'I accidentally called my professor \'mom\' in front of the entire lecture hall',
    ),
    BotUser(
      botId: 'bot_007',
      nickname: 'olivia',
      quineResponse: 'I\'ve been eating cereal for dinner every night this week because I\'m too lazy to cook',
    ),
    BotUser(
      botId: 'bot_008',
      nickname: 'grace',
      quineResponse: 'I pretend to be asleep when my roommate brings guys over because the walls are paper thin',
    ),
    BotUser(
      botId: 'bot_009',
      nickname: 'mia',
      quineResponse: 'I still sleep with a stuffed animal and I\'m not telling anyone which one',
    ),
    BotUser(
      botId: 'bot_010',
      nickname: 'ella',
      quineResponse: 'I have been ghosting this guy for a week because he uses the wrong \'your\' in texts',
    ),
    BotUser(
      botId: 'bot_011',
      nickname: 'riley',
      quineResponse: 'I told my parents I\'m getting straight A\'s but I\'m actually failing two classes',
    ),
    BotUser(
      botId: 'bot_012',
      nickname: 'zoe',
      quineResponse: 'I have been stealing toilet paper from the dorm bathrooms because I\'m too broke to buy my own',
    ),
    BotUser(
      botId: 'bot_013',
      nickname: 'luna',
      quineResponse: 'I cry in the library study rooms at least once a week and hope nobody notices',
    ),
    BotUser(
      botId: 'bot_014',
      nickname: 'ivy',
      quineResponse: 'I have never done laundry properly and just pray my clothes come out clean',
    ),
    BotUser(
      botId: 'bot_015',
      nickname: 'maya',
      quineResponse: 'I screenshot conversations with my crush and send them to my group chat for analysis',
    ),
    BotUser(
      botId: 'bot_016',
      nickname: 'kate',
      quineResponse: 'I have been wearing the same bra for four days because all my others are dirty',
    ),
    BotUser(
      botId: 'bot_017',
      nickname: 'ruby',
      quineResponse: 'I fake-laugh at everything my professor says because I need the participation grade',
    ),
    BotUser(
      botId: 'bot_018',
      nickname: 'sara',
      quineResponse: 'I still ask my mom to make doctor appointments for me because phone calls give me anxiety',
    ),
    BotUser(
      botId: 'bot_019',
      nickname: 'nora',
      quineResponse: 'I have been lying about my major to this guy because I think mine sounds boring',
    ),
    BotUser(
      botId: 'bot_020',
      nickname: 'leah',
      quineResponse: 'I eat in the bathroom stall sometimes because the dining hall is too overwhelming',
    ),
  ];

  static BotUser? getBotById(String botId) {
    try {
      return allBots.firstWhere((bot) => bot.botId == botId);
    } catch (e) {
      return null;
    }
  }

  static List<BotUser> getRandomBotSubset(int count, {int? seed}) {
    if (count > allBots.length) {
      throw ArgumentError('Cannot select $count bots from pool of ${allBots.length}');
    }

    final List<BotUser> shuffled = List.from(allBots);
    if (seed != null) {
      shuffled.shuffle(Random(seed));
    } else {
      shuffled.shuffle();
    }
    
    return shuffled.take(count).toList();
  }
}