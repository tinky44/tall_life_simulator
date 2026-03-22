extends RefCounted

const DATA: Dictionary = {
	"haruka": {
		"name": "はるか",
		"first_meet": [
			{"speaker": "はるか", "text": "おはよ。……あれ？"},
			{"speaker": "はるか", "text": "今日、なんか目線高くない？ また伸びた？"},
			{"speaker": "はるか", "text": "わ、見上げすぎて首いたくなりそう。"},
			{"speaker": "はるか", "text": "私、はるか。これからよろしくね。"},
		],
		"first_meet_elementary": [
			{"speaker": "はるか", "text": "おはよー！ ……あれ？"},
			{"speaker": "はるか", "text": "きょう、なんか めせん たかくない？ また のびた？"},
			{"speaker": "はるか", "text": "わっ、みあげすぎたら くび いたくなりそう。"},
			{"speaker": "はるか", "text": "わたし、はるか！ これから よろしくね。"},
		],
		"tall": [
			{"speaker": "はるか", "text": "ちょっと。また私のこと、ひじ置きにしようとしたでしょ。"},
			{"speaker": "はるか", "text": "でも、人混みでもすぐ見つけられるのは助かるんだよね。"},
		],
		"tall_elementary": [
			{"speaker": "はるか", "text": "あっ、また わたしを ひじおきに しようとしたでしょー。"},
			{"speaker": "はるか", "text": "でも、ひとごみでも すぐ みつけられるのは べんりだよね。"},
		],
		"huge": [
			{"speaker": "はるか", "text": "……ちょっと、また伸びた？"},
			{"speaker": "はるか", "text": "たまにはしゃがんでよ。内緒話しづらいじゃん。"},
		],
		"huge_elementary": [
			{"speaker": "はるか", "text": "うわ……また のびた？"},
			{"speaker": "はるか", "text": "ちょっと かがんでよ。ないしょばなし しにくいよ。"},
		],
		"height_check_invite": [
			{"speaker": "はるか", "text": "あ、ちょっと待って。"},
			{"speaker": "はるか", "text": "また背、伸びてない？"},
			{"speaker": "主人公", "text": "……そう、かな。"},
			{"speaker": "はるか", "text": "いや、絶対伸びてるって。保健室行こ、測ってもらおう。"},
		],
		"height_check_invite_elementary": [
			{"speaker": "はるか", "text": "あ、まって まって。"},
			{"speaker": "はるか", "text": "また せ、のびてない？"},
			{"speaker": "主人公", "text": "……そうかな。"},
			{"speaker": "はるか", "text": "ぜったい のびてるって。ほけんしつ いこ、はかってもらおう！"},
		],
		"measure_invite": [
			{"speaker": "はるか", "text": "ねえ……また背、伸びてない？"},
			{
				"speaker": "はるか",
				"text": "保健室、行こ。最近さ、自分ではどんな感じ？",
				"choices": [
					{"label": "ちょっと嬉しい", "next": "measure_invite_proud", "emotion": "confidence"},
					{"label": "目立つし、やっぱり恥ずかしい……", "next": "measure_invite_shy", "emotion": "complex"},
					{"label": "まだ、よくわからない", "next": "measure_invite_unsure"},
				]
			},
		],
		"measure_invite_elementary": [
			{"speaker": "はるか", "text": "ねえ……また せ、のびてない？"},
			{
				"speaker": "はるか",
				"text": "ほけんしつ いこ。いま、どんなかんじ？",
				"choices": [
					{"label": "ちょっとうれしい", "next": "measure_invite_proud", "emotion": "confidence"},
					{"label": "めだつの、いや……", "next": "measure_invite_shy", "emotion": "complex"},
					{"label": "よくわかんない", "next": "measure_invite_unsure"},
				]
			},
		],
		"measure_invite_proud": [
			{"speaker": "（主人公）", "text": "うん……ちょっと嬉しい。"},
			{"speaker": "はるか", "text": "そっか。なんか、その背ちゃんと似合ってるよ。"},
			{"speaker": "はるか", "text": "じゃ、何センチか見にいこ。"},
		],
		"measure_invite_proud_elementary": [
			{"speaker": "（主人公）", "text": "うん……ちょっとうれしい。"},
			{"speaker": "はるか", "text": "そっか！ そのせ、なんか かっこいいよ。"},
			{"speaker": "はるか", "text": "じゃ、はかりに いこ！"},
		],
		"measure_invite_shy": [
			{"speaker": "（主人公）", "text": "……目立つし、やっぱり恥ずかしい。"},
			{"speaker": "はるか", "text": "そっか。でも、一人で気にしてるより測ってすっきりしよ。"},
			{"speaker": "はるか", "text": "私も一緒に行くからさ。"},
		],
		"measure_invite_shy_elementary": [
			{"speaker": "（主人公）", "text": "……みんなに みられそうで、やだ。"},
			{"speaker": "はるか", "text": "そっか。でも、ひとりで もやもやするより はかってみよ。"},
			{"speaker": "はるか", "text": "わたしも いっしょに いくから。"},
		],
		"measure_invite_unsure": [
			{"speaker": "（主人公）", "text": "……自分でも、まだよくわかんない。"},
			{"speaker": "はるか", "text": "そっか。じゃあ、まず測ってみよ。"},
			{"speaker": "はるか", "text": "数字で見ると、少し気持ちが追いつくかも。"},
		],
		"measure_invite_unsure_elementary": [
			{"speaker": "（主人公）", "text": "……じぶんでも、よくわかんない。"},
			{"speaker": "はるか", "text": "そっか。じゃあ、まず はかってみよ。"},
			{"speaker": "はるか", "text": "すうじでみると、ちょっと わかるかも。"},
		],
		"measure_after": [
			{"speaker": "はるか", "text": "……やっぱり伸びてる。"},
			{"speaker": "はるか", "text": "次の学期もまた測ろう。今度も一緒ね。"},
		],
		"measure_after_elementary": [
			{"speaker": "はるか", "text": "……やっぱり のびてる！"},
			{"speaker": "はるか", "text": "つぎも いっしょに はかろうね。ぬけがけ なし！"},
		],
		"vball_join_cheer": [
			{"speaker": "はるか", "text": "バレー部！？ えっ、すごい決断だね。"},
			{"speaker": "はるか", "text": "絶対似合うって。思いっきり活躍してよ！"},
		],
		"vball_pain_consult": [
			{"speaker": "（主人公）", "text": "……はるか、ちょっと聞いてもいい？ 最近、脚が痛くて。"},
			{"speaker": "はるか", "text": "え、大丈夫？ それって練習のしすぎじゃないかな。"},
			{
				"speaker": "はるか",
				"text": "先輩に話した方がいいよ。ね、どうする？",
				"choices": [
					{"label": "先輩に伝えてもらう", "next": "pain_tell_senior", "action": "vball_pain_report"},
					{"label": "しばらく自分で頑張る", "next": "pain_endure"},
				]
			},
		],
		"pain_tell_senior": [
			{"speaker": "はるか", "text": "わかった、私から先輩に話しておくね。"},
			{"speaker": "はるか", "text": "無理しないで。体が一番大事だよ。"},
		],
		"pain_endure": [
			{"speaker": "はるか", "text": "……わかった。でも限界が来たら必ず言ってね。"},
		],
		"haruka_after_summer": [
			{"speaker": "はるか", "text": "うわあ、また大きくなってる！ 夏休みどうだったの？"},
			{"speaker": "はるか", "text": "バレー部、また続けるの？ 応援してるよ。"},
		],
		"term_school_haruka_support": [
			{"speaker": "はるか", "text": "今日の教室、しんどくない？ なんかずっと肩に力入ってるっぽい。"},
			{
				"speaker": "主人公",
				"text": "……どう返そう。",
				"choices": [
					{"label": "正直にしんどさを話す", "next": "term_school_haruka_open", "emotion": "confidence", "action": "stress:-5,note:はるかに教室で感じるしんどさを打ち明けられた。"},
					{"label": "大丈夫だと笑ってごまかす", "next": "term_school_haruka_hold", "emotion": "complex", "action": "stress:+2,note:はるかの前でも大丈夫なふりをしてしまった。"},
				]
			},
		],
		"term_school_haruka_support_elementary": [
			{"speaker": "はるか", "text": "きょうの きょうしつ、だいじょうぶ？ なんか ずっと かたに ちから はいってるよ。"},
			{
				"speaker": "主人公",
				"text": "……どう こたえよう。",
				"choices": [
					{"label": "ほんとのことを はなす", "next": "term_school_haruka_open", "emotion": "confidence", "action": "stress:-5,note:はるかに教室で感じるしんどさを打ち明けられた。"},
					{"label": "だいじょうぶって いう", "next": "term_school_haruka_hold", "emotion": "complex", "action": "stress:+2,note:はるかの前でも大丈夫なふりをしてしまった。"},
				]
			},
		],
		"term_school_haruka_open": [
			{"speaker": "主人公", "text": "視線が集まるたび、ただ立ってるだけで疲れる時がある。"},
			{"speaker": "はるか", "text": "そっか。つらい日はさ、席でも保健室でも一緒に行こ。"},
		],
		"term_school_haruka_open_elementary": [
			{"speaker": "主人公", "text": "みんなに みられると、ただ たってるだけで つかれちゃう。"},
			{"speaker": "はるか", "text": "そっか。つらい日は せきでも ほけんしつでも、わたしと いっしょに いこ。"},
		],
		"term_school_haruka_hold": [
			{"speaker": "主人公", "text": "……平気。たぶん、いつものことだから。"},
			{"speaker": "はるか", "text": "そっか。でも、無理してる時ってけっこう分かるよ。あとででも声かけて。"},
		],
		"term_school_haruka_hold_elementary": [
			{"speaker": "主人公", "text": "……へいき。たぶん、だいじょうぶ。"},
			{"speaker": "はるか", "text": "そっか。でも、むりしてるとき わかるよ。あとででも こえかけてね。"},
		],
	},
	"senior": {
		"first_meet": [
			{"speaker": "バレー部先輩", "text": "君、ちょっといいかな？"},
			{"speaker": "バレー部先輩", "text": "……すごいな、ネットより頭一つ高いじゃないか"},
			{"speaker": "バレー部先輩", "text": "バレー部、興味ない？ 君なら無敵のアタッカーになれるよ。"},
			{"speaker": "バレー部先輩", "text": "もし気が向いたら、体育館に顔を出してみてくれ。"},
		],
		"huge": [
			{"speaker": "バレー部先輩", "text": "（驚きながら）……また大きくなったか？"},
			{"speaker": "バレー部先輩", "text": "体育館の入り口、頭ぶつけないように気をつけろよ。"},
		],
		"join_invite": [
			{"speaker": "バレー部先輩", "text": "体育館に来てくれたか。改めて、入部どうだ？"},
			{
				"speaker": "バレー部先輩",
				"text": "身長も才能のうちだ。一緒にやってみないか？",
				"choices": [
					{"label": "入部する！", "next": "join_accepted", "action": "vball_join"},
					{"label": "もう少し考えたい……", "next": "join_think"},
					{"label": "やっぱりやめておく", "next": "join_decline"},
				]
			},
		],
		"join_accepted": [
			{"speaker": "バレー部先輩", "text": "よし！ ようこそバレー部へ。"},
			{"speaker": "バレー部先輩", "text": "まず基本から教えるよ。一緒に頑張ろう。"},
		],
		"join_think": [
			{"speaker": "バレー部先輩", "text": "そうか。また来たときに声をかけてくれ。"},
		],
		"join_decline": [
			{"speaker": "バレー部先輩", "text": "残念だけど、気が変わったらいつでも来い。"},
		],
		"practice_first": [
			{"speaker": "バレー部先輩", "text": "最近の練習、だいぶ慣れてきたな。"},
			{"speaker": "バレー部先輩", "text": "……でも、右脚、大丈夫か？ 少しかばってるように見えるけど。"},
		],
		"pain_concern": [
			{"speaker": "バレー部先輩", "text": "はるかから聞いたよ。脚が痛いんだって？"},
			{"speaker": "バレー部先輩", "text": "今は無理するな。しばらく休部して、ちゃんと診てもらえ。"},
			{"speaker": "バレー部先輩", "text": "治ったらいつでも戻ってこい。待ってるから。"},
		],
		"senior_after_summer": [
			{"speaker": "バレー部先輩", "text": "おい……夏休みの間にまた大きくなったか！"},
			{"speaker": "バレー部先輩", "text": "脚の具合はどうだ？ 続けられそうか？"},
			{
				"speaker": "バレー部先輩",
				"text": "正直に教えてくれ。",
				"choices": [
					{"label": "また頑張りたい！", "next": "vball_return", "action": "vball_rejoin"},
					{"label": "マネージャーとして関わりたい", "next": "vball_manager", "action": "vball_manager_role"},
					{"label": "今は勉強に集中したい……", "next": "vball_retire"},
				]
			},
		],
		"vball_return": [
			{"speaker": "バレー部先輩", "text": "よし！ 待ってたぞ。今学期も一緒に頑張ろう。"},
		],
		"vball_manager": [
			{"speaker": "バレー部先輩", "text": "マネージャーか。それも大切な役割だよ。よろしく。"},
		],
		"vball_retire": [
			{"speaker": "バレー部先輩", "text": "そうか……ゆっくり考えてくれ。応援してるよ。"},
		],
	},
	"mother": {
		"first_meet": [
			{"speaker": "お母さん", "text": "おかえり。ご飯もうすぐできるよ。"},
			{"speaker": "お母さん", "text": "立って？ ……また背、伸びたんじゃない？"},
		],
		"check": [
			{"speaker": "お母さん", "text": "あら、また制服の丈が短くなったわね。"},
			{"speaker": "お母さん", "text": "もうミニスカートどころじゃないわよ。"},
			{"speaker": "お母さん", "text": "夏休みの間に何があったの？ 急成長しすぎじゃない？"},
		],
	},
	"father": {
		"first_meet": [
			{"speaker": "お父さん", "text": "おかえり。"},
			{"speaker": "お父さん", "text": "……背、伸びたな。"},
		],
		"check": [
			{"speaker": "お父さん", "text": "……。"},
			{"speaker": "お父さん", "text": "いつの間にか、お父さんより頭二つ分も大きいんだな。"},
			{"speaker": "お父さん", "text": "天井の電球、替えてくれるかい？"},
		],
	},
	"teacher": {
		"semester_start": [
			{"speaker": "田中先生", "text": "起立、礼。着席。"},
			{"speaker": "田中先生", "text": "新学期ですね。今学期も、きちんとやっていきましょう。"},
			{"speaker": "田中先生", "text": "……また背が伸びましたか。前だと後ろが見えにくいので、今日から後ろの席にしてください。"},
		],
		"semester_start_elementary": [
			{"speaker": "田中先生", "text": "起立、礼。はい、座りましょう。"},
			{"speaker": "田中先生", "text": "新学期が始まりました。今学期もよろしくね。"},
			{"speaker": "田中先生", "text": "……また背が伸びたのね。前の席だとみんなが黒板を見にくいから、今日は後ろに座ってちょうだい。"},
		],
	},
	"nurse": {
		"default": [
			{"speaker": "保健の先生", "text": "今日も身長を測りに来たの？ ふふ、本当に伸びるのが早いわね。"},
			{"speaker": "保健の先生", "text": "じゃあ身長計の前へどうぞ。背すじをすっと伸ばしてね。"},
		],
		"default_elementary": [
			{"speaker": "保健の先生", "text": "今日も背を測りに来たの？ えらいわ、ちゃんと覚えてたのね。"},
			{"speaker": "保健の先生", "text": "じゃあここに立って。背中をぴんとしてみましょうか。"},
		],
		"measurement_notice": [
			{"speaker": "保健の先生", "text": "そろそろ身体測定の時期ね。時間がある時に保健室へいらっしゃい。先に測っておくと安心よ。"},
		],
		"measurement_notice_elementary": [
			{"speaker": "保健の先生", "text": "もうすぐ身体測定だから、あとで保健室においで。先生が見てあげるからね。"},
		],
		"measurement_in_progress": [
			{"speaker": "保健の先生", "text": "靴を脱いで、身長計に乗ってね。大丈夫、すぐ終わるから。"},
			{"speaker": "保健の先生", "text": "はい、そのままじっとして。上手よ。"},
		],
		"measurement_in_progress_elementary": [
			{"speaker": "保健の先生", "text": "靴を脱いで、この上に乗ってね。慌てなくて大丈夫よ。"},
			{"speaker": "保健の先生", "text": "うん、そのまま。じょうずにできてるわ。"},
		],
	},
	"player": {
		"too_big_for_house": [
			{"speaker": "（主人公）", "text": "家より大きくなっちゃった……。"},
			{"speaker": "（主人公）", "text": "左の公園にある巨大テントなら、休めるかも。"},
		],
		"too_big_for_school": [
			{"speaker": "（主人公）", "text": "学校より大きくなっちゃった……。"},
		],
		"too_big_for_station": [
			{"speaker": "（主人公）", "text": "駅より大きくなっちゃった……。"},
		],
		"summer_growth": [
			{"speaker": "（主人公）", "text": "……制服のボタン、止まらない。"},
			{"speaker": "（主人公）", "text": "夏休みの間に、こんなに伸びてたの？"},
		],
		"new_semester": [
			{"speaker": "（主人公）", "text": "新学期か……。"},
			{"speaker": "（主人公）", "text": "また少し背が伸びた気がする。今学期も色々あるんだろうな。"},
		],
		"new_semester_elementary": [
			{"speaker": "（主人公）", "text": "しんがっきだ。"},
			{"speaker": "（主人公）", "text": "また ちょっと せが のびたかも。こんがっきは どうなるかな。"},
		],
		"term_home_mirror": [
			{"speaker": "（主人公）", "text": "洗面台の鏡に、自分の姿がすっぽり映る。"},
			{"speaker": "（主人公）", "text": "こうして見ると、やっぱり大きい。でも今日は、少しだけ落ち着いて見られた。"},
		],
		"term_home_table": [
			{"speaker": "お母さん", "text": "ちょうどお茶を入れたところ。少し座っていく？"},
			{
				"speaker": "（主人公）",
				"text": "食卓の前で立ち止まる。どうしよう。",
				"choices": [
					{"label": "そのまま一緒に座る", "next": "term_home_table_stay", "emotion": "confidence", "action": "stress:-4,note:食卓で家族と一緒に座る時間を取れた。"},
					{"label": "やっぱり部屋に戻る", "next": "term_home_table_leave", "emotion": "complex", "action": "stress:+2,note:食卓の前で少しためらってから部屋に戻った。"},
				]
			},
		],
		"term_home_table_stay": [
			{"speaker": "（主人公）", "text": "椅子に座って、お茶をひと口飲む。"},
			{"speaker": "お母さん", "text": "そのくらいゆっくりしていきなさい。家では、気を張らなくていいんだから。"},
		],
		"term_home_table_leave": [
			{"speaker": "（主人公）", "text": "……今日は、まだうまく座れそうにない。"},
			{"speaker": "お母さん", "text": "そっか。また気が向いたら来て。お茶、いつでも入れるから。"},
		],
		"term_school": [
			{"speaker": "（主人公）", "text": "また後ろの席だ。みんなの視線が、少しだけ気になる。"},
			{
				"speaker": "（主人公）",
				"text": "でも、今学期はどう向き合おう？",
				"choices": [
					{"label": "目立っても、ちゃんと通う", "next": "term_school_brave", "emotion": "confidence", "action": "stress:-4"},
					{"label": "やっぱり少ししんどい", "next": "term_school_tired", "emotion": "complex", "action": "stress:+4"},
				]
			},
		],
		"term_school_elementary": [
			{"speaker": "（主人公）", "text": "また いちばん うしろの せきだ。みんなの めが、ちょっと きになる。"},
			{
				"speaker": "（主人公）",
				"text": "こんがっき、どうしよう？",
				"choices": [
					{"label": "めだっても がんばって いく", "next": "term_school_brave", "emotion": "confidence", "action": "stress:-4"},
					{"label": "やっぱり ちょっと しんどい", "next": "term_school_tired", "emotion": "complex", "action": "stress:+4"},
				]
			},
		],
		"term_school_brave": [
			{"speaker": "（主人公）", "text": "……大丈夫。見られても、ちゃんとここにいる。"},
			{"speaker": "はるか", "text": "うん、その調子。今学期も一緒にやっていこう。"},
		],
		"term_school_brave_elementary": [
			{"speaker": "（主人公）", "text": "……だいじょうぶ。みられても、ちゃんと いく。"},
			{"speaker": "はるか", "text": "うん、そのちょうし。こんがっきも いっしょだよ。"},
		],
		"term_school_tired": [
			{"speaker": "（主人公）", "text": "……ちょっと、息が詰まる。"},
			{"speaker": "はるか", "text": "無理しすぎないでね。しんどい時は、ちゃんと休もう。"},
		],
		"term_school_tired_elementary": [
			{"speaker": "（主人公）", "text": "……ちょっと、むねが きゅってする。"},
			{"speaker": "はるか", "text": "むりしすぎないでね。しんどかったら、ちゃんと やすも。"},
		],
		"term_school_seat": [
			{"speaker": "（主人公）", "text": "自分の席に座る。机の高さは昔のままなのに、見える景色だけが少し変わっている。"},
			{"speaker": "（主人公）", "text": "落ち着かない。でも、ここで過ごすしかないんだ。"},
		],
		"term_school_seat_elementary": [
			{"speaker": "（主人公）", "text": "じぶんの せきに すわる。つくえは おなじなのに、みえる けしきだけ ちょっと ちがう。"},
			{"speaker": "（主人公）", "text": "なんだか そわそわする。でも、ここで すごすんだ。"},
		],
		"term_school_infirmary": [
			{"speaker": "保健の先生", "text": "顔が少しかたいわね。座って、少し話してみる？"},
			{
				"speaker": "（主人公）",
				"text": "……どうしよう。ちゃんと話したほうがいいかな。",
				"choices": [
					{"label": "しんどさを正直に話す", "next": "term_school_infirmary_open", "emotion": "confidence", "action": "stress:-6,note:保健室でしんどさを正直に話せた。"},
					{"label": "平気だと言って戻る", "next": "term_school_infirmary_hold", "emotion": "complex", "action": "stress:+3,note:保健室でも平気なふりをしてしまった。"},
				]
			},
		],
		"term_school_infirmary_elementary": [
			{"speaker": "保健の先生", "text": "顔が少しかたいわね。座って、ちょっとお話ししてみる？"},
			{
				"speaker": "（主人公）",
				"text": "……どうしよう。ほんとのこと、いったほうが いいかな。",
				"choices": [
					{"label": "しんどいって はなす", "next": "term_school_infirmary_open", "emotion": "confidence", "action": "stress:-6,note:保健室でしんどさを正直に話せた。"},
					{"label": "だいじょうぶって いう", "next": "term_school_infirmary_hold", "emotion": "complex", "action": "stress:+3,note:保健室でも平気なふりをしてしまった。"},
				]
			},
		],
		"term_school_infirmary_open": [
			{"speaker": "（主人公）", "text": "……最近、視線が気になって、ずっと肩に力が入るんです。"},
			{"speaker": "保健の先生", "text": "話してくれてよかった。無理して平気なふりをするより、そうして教えてくれるほうが先生は安心するわ。"},
		],
		"term_school_infirmary_open_elementary": [
			{"speaker": "（主人公）", "text": "……みんなの めが きになって、ずっと かたに ちからが はいっちゃう。"},
			{"speaker": "保健の先生", "text": "話してくれてありがとう。無理してがまんするより、ちゃんと先生に教えてくれるほうがずっといいの。"},
		],
		"term_school_infirmary_hold": [
			{"speaker": "（主人公）", "text": "……大丈夫です。ちょっと疲れてるだけです。"},
			{"speaker": "保健の先生", "text": "そう。無理はしないでね。つらくなったら、いつでも戻っていらっしゃい。"},
		],
		"term_school_infirmary_hold_elementary": [
			{"speaker": "（主人公）", "text": "……だいじょうぶ。ちょっと つかれただけ。"},
			{"speaker": "保健の先生", "text": "そう。つらくなったら、また先生のところへおいで。"},
		],
		"term_station_bench": [
			{"speaker": "（主人公）", "text": "ベンチに腰を下ろす。人の流れを見ていると、自分だけ少し別の速さで立っていた気がした。"},
			{"speaker": "（主人公）", "text": "少し休むだけで、肩の力がほんの少し抜けていく。"},
		],
		"term_station_vending": [
			{"speaker": "（主人公）", "text": "自販機の前で立ち止まる。ボタンは低いのに、なぜか視線だけは高いところまで届く気がした。"},
			{"speaker": "（主人公）", "text": "ただ立っているだけで目立つ。そんな感覚が、駅前ではいちばん強い。"},
		],
		"gymnasium_basket_reach": [
			{"speaker": "（主人公）", "text": "腕をまっすぐ伸ばすと、ゴールが前より少しだけ近く見えた。"},
			{"speaker": "（主人公）", "text": "届くかどうかより、体が素直に上へ伸びる感覚のほうがうれしかった。"},
		],
		"entrance_elementary": [
			{"speaker": "（主人公）", "text": "きょうは しょうがっこうの にゅうがくしきだ。"},
			{"speaker": "（主人公）", "text": "ランドセル、ちょっと おもい。でも たのしみ。"},
		],
		"entrance_middle": [
			{"speaker": "（主人公）", "text": "今日は中学校の入学式だ。"},
			{"speaker": "（主人公）", "text": "制服の袖が、もうギリギリだ。"},
		],
		"entrance_high": [
			{"speaker": "（主人公）", "text": "今日は高校の入学式だ。"},
			{"speaker": "（主人公）", "text": "式場に入ったら、また一番後ろに立たされた。"},
		],
		"summer_growth_vball": [
			{"speaker": "（主人公）", "text": "……制服のボタン、全然止まらない。"},
			{"speaker": "（主人公）", "text": "夏休みの間に、こんなに伸びてたの？"},
			{"speaker": "（主人公）", "text": "……来学期、部活に戻れるかな。脚の具合も気になるし。"},
		],
		"randoseru_farewell": [
			{"speaker": "（主人公）", "text": "……ランドセル。いつの間にか、小さく見える。"},
			{
				"speaker": "（主人公）",
				"text": "持ってみようか、どうしよう。",
				"choices": [
					{"label": "片づける", "next": "randoseru_farewell_pack", "emotion": "confidence", "action": "stress:-2,note:ランドセルを静かに片づけた。"},
					{"label": "少し名残惜しく眺める", "next": "randoseru_farewell_look", "action": "note:ランドセルをしばらく眺めた。"},
					{"label": "肩に当ててみる", "next": "randoseru_farewell_hold", "action": "stress:+1"},
				]
			},
		],
		"randoseru_farewell_pack": [
			{"speaker": "（主人公）", "text": "棚の奥にしまう。もうここに入学式はない。"},
		],
		"randoseru_farewell_look": [
			{"speaker": "（主人公）", "text": "少しの間、眺めてから棚に戻した。"},
			{"speaker": "（主人公）", "text": "小さく見えるけど、このランドセルの頃は全部ちゃんとあった。"},
		],
		"randoseru_farewell_hold": [
			{"speaker": "（主人公）", "text": "肩に合わない。持ち方も、もうよく分からない。"},
			{"speaker": "（主人公）", "text": "……似合わなくなったんだ。"},
		],
		"growth_spurt": [
			{"speaker": "（主人公）", "text": "……なんか、いつもと高さが違う気がする。"},
			{"speaker": "（主人公）", "text": "床から目線まで、急に遠くなった感じがした。"},
			{"speaker": "お母さん", "text": "ちょっと、また伸びた？ この学期だけで随分変わったわね。"},
			{"speaker": "（主人公）", "text": "……そういう時期なのかな。自分でも、よく分からない。"},
		],
		"high_scout_contact": [
			{"speaker": "（主人公）", "text": "封筒が届いていた。差出人は、地域のスポーツクラブ。"},
			{"speaker": "（主人公）", "text": "「一度見学に来てみませんか」"},
			{
				"speaker": "（主人公）",
				"text": "……どうしよう。",
				"choices": [
					{"label": "見学してみたい", "next": "high_scout_consider", "emotion": "confidence", "action": "high_scout_interest,note:スポーツクラブからの勧誘を前向きに受け取った。"},
					{"label": "今は断る", "next": "high_scout_decline", "action": "note:スポーツクラブからの勧誘を断った。"},
					{"label": "はるかに相談してみる", "next": "high_scout_consult", "action": "note:勧誘のことをはるかに相談した。"},
				]
			},
		],
		"high_scout_consider": [
			{"speaker": "（主人公）", "text": "外から「才能があるかも」と言われるのは、やっぱりちょっとうれしかった。"},
			{"speaker": "（主人公）", "text": "まず、見学だけでいい。それから考えよう。"},
		],
		"high_scout_decline": [
			{"speaker": "（主人公）", "text": "今は、外の話に乗る気になれない。"},
			{"speaker": "（主人公）", "text": "もう少し、自分のペースで行きたい。"},
		],
		"high_scout_consult": [
			{"speaker": "（主人公）", "text": "はるかなら、どう思うだろう。"},
			{"speaker": "はるか", "text": "え、クラブの人から手紙？ すごいじゃん！"},
			{"speaker": "はるか", "text": "行ってみたら？ 見るだけでもいいと思うよ。"},
		],
		"elem_tease": [
			{"speaker": "男子", "text": "ねえ、せ たかくない？"},
			{"speaker": "男子", "text": "また のびたの？ すごくね？"},
			{
				"speaker": "（主人公）",
				"text": "（なんて いえば いいんだろう）",
				"choices": [
					{"label": "気にしないでいる", "next": "elem_tease_ignore", "emotion": "confidence", "action": "stress:-2"},
					{"label": "少しだけへこむ", "next": "elem_tease_sad", "emotion": "complex", "action": "stress:+3"},
				]
			},
		],
		"elem_tease_ignore": [
			{"speaker": "（主人公）", "text": "……きにしない。けど、なんか ずっと のこる。"},
			{"speaker": "はるか", "text": "だいじょうぶだよ。あの子たち、いじわるっていうより びっくりしただけだよ。"},
		],
		"elem_tease_sad": [
			{"speaker": "（主人公）", "text": "（ちょっと かなしかった。）"},
			{"speaker": "はるか", "text": "へんじゃないよ。気にしなくて いいからね。"},
		],
	},
	"park_giant": {
		"first_meet": [
			{"speaker": "大男", "text": "お、見ない顔だな。ここは大きいものがあるから落ち着けるんだ。"},
			{"speaker": "大男", "text": "俺はちょうど200cm。滑り台もジャングルジムも、やっと目線が合う。"},
		],
		"default": [
			{"speaker": "大男", "text": "家の中が窮屈な日は、この公園に来ると少し息がしやすい。"},
			{"speaker": "大男", "text": "でかい遊具を見てると、自分だけがはみ出してるわけじゃないって思えるんだよ。"},
		],
		"tall": [
			{"speaker": "大男", "text": "その目線、もうこっちに近いな。普通の街より、公園のほうが落ち着くだろ。"},
		],
		"over_200": [
			{"speaker": "大男", "text": "えっ、200cmの俺よりでかいだと？"},
			{"speaker": "大男", "text": "はは、驚いたよ。人を見上げるなんていつぶりだろう。しかも女の子を…"},
		],
		"huge": [
			{"speaker": "大男", "text": "はは、ついに俺よりでかいのが来たか。巨大身長計も喜びそうだな。"},
		],
	},
	"narrator": {
		"growing_pain_sleep": [
			{"speaker": "", "text": "ミシミシ……ミシミシ……"},
			{"speaker": "", "text": "膝が音を立てている。"},
			{"speaker": "主人公（心の声）", "text": "……また、伸びてるのかな。"},
		],
		"growing_pain_sleep_intense": [
			{"speaker": "", "text": "ミシミシ……ミシミシ……"},
			{"speaker": "", "text": "ガキッ……ガキッ……"},
			{"speaker": "主人公（心の声）", "text": "骨が……割れるような音がする……！"},
			{"speaker": "主人公（心の声）", "text": "いたい……いたい……"},
		],
		"refrigerator_milk": [
			{"speaker": "主人公", "text": "冷蔵庫を開けると、牛乳がある。"},
			{"speaker": "主人公", "text": "……ぐびぐびぐび。"},
			{"speaker": "主人公（心の声）", "text": "（また伸びる気がする）"},
		],
		"growth_sleep_warning": [
			{"speaker": "主人公（心の声）", "text": "……急に、どっと眠気が来た。"},
			{"speaker": "主人公（心の声）", "text": "体が重い。目が開かない。"},
			{"speaker": "__choice__", "choices": ["今すぐ帰って寝る", "もう少し頑張る"]},
		],
		"growth_supplement_found": [
			{"speaker": "主人公", "text": "自動販売機の取り出し口に、何かある……"},
			{"speaker": "主人公", "text": "『怪しい成長サプリ』？"},
			{"speaker": "主人公（心の声）", "text": "……飲むか？"},
			{"speaker": "__choice__", "choices": ["飲む", "捨てる"]},
		],
	},
	"park_vendor": {
		"default": [
			{"speaker": "主人公（心の声）", "text": "公園の端に、妙に静かな無人販売所がある。"},
			{"speaker": "主人公（心の声）", "text": "棚には『+10cm』とだけ書かれた瓶がひとつ残っていた。"},
			{"speaker": "主人公（心の声）", "text": "飲んだあと、背骨の奥がじんと熱くなった。"},
		],
		"repeat": [
			{"speaker": "主人公（心の声）", "text": "さっきまで空だったはずの棚に、また瓶が置かれていた。"},
			{"speaker": "主人公（心の声）", "text": "ついもう一本手に取ってしまう。"},
		],
	},
	"generic": {
		"first_meet": [
			{"speaker": "人", "text": "えっ……！？"},
			{"speaker": "人", "text": "（信じられないものを見るように見上げている）"},
		],
		"npc_talk_tall": [
			{"speaker": "同級生", "text": "ねえ、バスケ部入ってるの？ 絶対向いてるって！"},
			{"speaker": "同級生", "text": "その高さ、ちょっと羨ましいな。"},
		],
		"npc_talk_tall_elementary": [
			{"speaker": "同級生", "text": "ねえねえ、バスケ やってるの？"},
			{"speaker": "同級生", "text": "その せ、ちょっとうらやましいな。"},
		],
		"npc_talk_huge": [
			{"speaker": "通行人", "text": "……モデルさんですか？"},
			{
				"speaker": "（主人公）",
				"text": "（なんて答えればいいんだろう）",
				"choices": [
					{"label": "笑って『違います』と言う", "emotion": "confidence", "action": "stress:-2"},
					{"label": "目をそらす", "emotion": "complex", "action": "stress:+4"}
				]
			},
		],
		"npc_talk_veryhuge": [
			{"speaker": "周囲の人", "text": "えっ……ほんとに大きい。"},
			{
				"speaker": "（主人公）",
				"text": "（ざわつきが一斉にこっちへ向く）",
				"choices": [
					{"label": "軽く会釈する", "emotion": "confidence", "action": "stress:-1"},
					{"label": "肩をすくめてやり過ごす", "emotion": "complex", "action": "stress:+5"}
				]
			},
		],
		"npc_firstvisit_gymnasium": [
			{"speaker": "体育教師", "text": "おっ、新しい顔か。君、バレー部に向いてそうだな。"},
		],
		"middle_boys_growth_talk": [
			{"speaker": "男子", "text": "俺、最近5cm伸びたぞ！"},
			{"speaker": "男子", "text": "マジ？ 俺も！ 最近ぐっと来た感じがする。"},
			{"speaker": "（主人公）", "text": "（5cm。それが大きな話になってる。私は……）"},
			{"speaker": "（主人公）", "text": "（今学期だけでもっと伸びてるけど、黙ってよう。）"},
		],
		"huge": [
			{"speaker": "人", "text": "モデルさんみたい！"},
			{"speaker": "人", "text": "天井、頭届きそう？"},
		],
		"tall": [
			{"speaker": "人", "text": "背高いね。バスケ向いてそう！"},
			{"speaker": "人", "text": "ちょっと棚の上の荷物取ってくれる？"},
		],
		"default": [
			{"speaker": "人", "text": "今日もすっきりしてるね。"},
			{"speaker": "人", "text": "話しかけやすくて助かるよ。"},
		]
	},
}
