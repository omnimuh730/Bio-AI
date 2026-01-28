## Dashboard

- Bio sync states -> how to implement this?
Syncing or fetching every few seconds every few seconds is not battery-efficiency, also apple watch does not provide real-time data, just provide aggregated past data at once.

- Notification
Aggregate daily record, `$where source = system`
e.g.:
system record: you overweighted colories 3150/2750 cal
user record: input of food like sandwich with calorie, its category information {bread: xcal, butter: xcal, ... meta: {...}}

- Live vitals
Aggregate data from wearable devices.
Small rules for showing like high stress -> this is fetched by DB Live Vitals Rules table.

- Quick log
Copy Yesterday Breakfast - People often do repeated meals especially like meals or lunch.

- Hydration - recover water+250, +500, +custom(modal showing) when card click


If Coffee or alchol option is clicked, notify/alert every time even +250 or +500 is clicked like getting alchol is not included in hydration getting.

- Dailly Fuel

2 rings we have

Outside ring -> time bar
inside ring(currently implemented) calary obtained bar.

Status(center located label -> if time bar is behind of calory bar, able to eat, suggest eat, if it is not, not suggest or if time passed, just suggest light snack)

- AI recommend
this have 2 button looks like refresh
1. refresh(recommend others)
2. i dislike it(popup shows and select option like this is too expensive, i dislike it, recommendation is not correct...)

## Camera Page
If screenshot button is clicked -> Process -> 1st Recognition Result(Is this image for food)(Yes/No)

If No, go back to camera again.If Yes, Analyze(recognize food, categories and calculate volume, calorie)

If Offline Mode is on -> Just save to back up -> Limit 10 images.

Search->
1. Barcode -> Recognize -> google or perplexity api search -> confirmation step -> add
2. Mannual Input or Voice recognition in the input field for text search -> DB scan

## Analytics

Energy Score logic based on Calorie, sleep status, protein, activity...
Weekly/Monthly/Daily Chart


## Profile Settings
- Force re-sync -> Force Load health data from connected wearable devices.

- Find Devices - show modal, split into 2 views: added devices(removable), available devices(finding)

- Diatery rules
4~5 trend words(fetch from db statistics -> backend should make statistic this), other->custom input option

- Units & alerts -> current implementation is good.

- Goal Setting
checkbox options, custom input, Transfer to favorate list -> this shows on goal setting.
Explanation sentence for this: Setted Goals is ..., ..., ..., so i'll prefer to recommend foods that obtains much protein, ....

- Subscription - should have some fantasy card style themes or other theme design for selecting Tier.

## Onboarding Step
Show great images as part of the advertise of this app in each step but this should not make the app slow down.
## Planner

- Eat out -> modal popup -> allow gps or mannual enter.

- Search Menu
1. Perplexity or gemini ai api to recommend nearby restaurants
2. get food list by googling nearby those selected restaurants.
3. ai model to get structured json of those foods

- Coach Menu

1. Self Training Model - Preference calculate(Dashboard page dislike)
2. calculation logic should be implemented -> health match score(from completion result of Search Menu result), preference score

- Smart Pantry

1. Input field(for input materials or food categories like carrot or olive oil) to register things at home.(typing, voice input, camera, if typing or voice input ask amount)
2. View Recipie
Name list -> chip button -> I hate this...
Missing label(currently implemented but only shows like lemon): lemoon and 3 other materials.

- Cook at home -> Left Over
Static calculate this.
Log, Delete, Edit(ajust amount of material) -> 2 buttons for each materials like olive oil, sugar, vanilla...
Log(used it) -> show slidebar to set used status -> calculate and round up amount like 50% of 3 potatoes is 1 or 2, 50% of 10 pond olive oil is 5pond olive.
while grabbing slidebar, show its usage like you've used 2 potatoes or 3 pond of sugar.



---

# Noticable backend logics.

- Calculating calorie logic.
SAM(detect and classifying materials) Model -> Depth Anything v2(get Volume) -> Qwen2.5 lv or any other vision models like openai(wanna use fastest gpt model for latency) to get calculation of calory per unit of the item.

- How to measure volume of object?
On the camera page, there's an overlay layer that shows ghost hand or drugnov snipergun like meter unit pattern on the camera showing.

Gyroscope works together, ask users to fit 45'(users can't fit exactly 45' so accept from 40' to 50').

Capture is only available when gyroscope is fit in this range.

Once camera angle is immutable like this and show such meter pattern graph as the overlay image, user can find a place to capture 45' angle, 1 feet distance.
user can user fingers or other objects to align the dragnovlike pattern, and if this repeats several times, users can easily fit(ofc even in this case, such pattern still shows).

If angle is measured, distance is measured, we can measure how many pixcel does it cover for per feet or inch in the shotted image so we can get depth map, exact distance.
This is the way of getting distance and accurate volume without using of LiDar of iPhone Pro.

User should be able to upload relevant images.
So as part of the meta image of sandwich, user can add additional images by clicking specific meta image button so like cooking image or restaurant image that made the food like that.
So they can share with friends or on social media.
But this meta image is not used for calculating or training purpose.


# Purpose of this flow.

1. Suggest and calculate accurate calorie at the lowest cost.

2. Establish strong database(image:json) so when we start, we rely on openai api but time passes and if userbase is over 100000MAU, we can use our own model that is trained by these datas.
Such data is really valuable.

# Another specs

Use serverless GPU for calculating like using Depth anything or SAM.
use aws s3 for image storing but very well indexing, optimization, partitioning is required
Very storng infrastructure is required.
Very stong db schema is required(either this is non-relational or relational)
I think health, calory schema is dynamic, should be extendable so non-relational would be efficient.
Very strong skills of db handling like Time-series db like for indexing, searching foods for recommendation.

Reliable proved logic of calculating energy score based on health status(stress, sleep, heartbeat)
and very strong ai engine or rule for combining this with preference, calory information of food.
