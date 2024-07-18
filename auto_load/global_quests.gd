extends Node

## An array of dictionaries that will hold quest details. These dictionaries will be appended to the array on ready, based on what..
## .. is written inside of a saved file. I could either have a preset list it goes through over time, or just incrementally increase..
## .. targets on quest frames. To be honest the second would likely be best as there aren't a huge load of quest possibilites.
var quests = []

## While running, a timer will begin under physics process that resets every 5 seconds, calling a refresh quests function.
## This will compare each quest's target goal to the current value of the tracked stat. If over the target, it will call a quest..
## .. complete function that will get the index of the completed quest, update that specific quest based on a function or something..
## .. and update the quest details in the saved file. Rewards will be granted too, which will likely be held in a new saved file.
