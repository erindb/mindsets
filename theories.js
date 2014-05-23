function caps(a) {return a.substring(0,1).toUpperCase() + a.substring(1,a.length);}
function uniform(a, b) { return ( (Math.random()*(b-a))+a ); }
function showSlide(id) { $(".slide").hide(); $("#"+id).show(); }
function shuffle(v) { newarray = v.slice(0);for(var j, x, i = newarray.length; i; j = parseInt(Math.random() * i), x = newarray[--i], newarray[i] = newarray[j], newarray[j] = x);return newarray;} // non-destructive.
function sample(v) {return(shuffle(v)[0]);}
function rm(v, item) {if (v.indexOf(item) > -1) { v.splice(v.indexOf(item), 1); }}
function rm_sample(v) {var item = sample(v); rm(v, item); return item;}
function sample_n(v, n) {var lst=[]; var v_copy=v.slice(); for (var i=0; i<n; i++) {lst.push(rm_sample(v_copy))}; return(lst);}
function rep(e, n) {var lst=[]; for (var i=0; i<n; i++) {lst.push(e);} return(lst);}
var startTime;

function article(diff) {
  return diff == "easy" ? "an" : "a";
}

var names = ["Adam", "Bob", "Carl", "Dave", "Evan", "Fred", "George",
             "Hank", "Ivan", "John", "Kevin", "Luke", "Mark", "Nick",
             "Oscar", "Patrick", "Rick", "Steve", "Tom", "Vince",
             "Will", "Zach", "Ben", "Brian", "Colin", "Dan",
             "Edward", "Felix", "Gabe", "Greg", "Henry", "Jack", "Jeff",
             "Joe", "Josh", "Keith", "Kyle", "Matt", "Martin", "Max",
             "Mike", "Paul", "Phillip", "Toby", "Andrew", "Charles",
             //fix this
             "Adam", "Bob", "Carl", "Dave", "Evan", "Fred", "George",
             "Hank", "Ivan", "John", "Kevin", "Luke", "Mark", "Nick",
             "Oscar", "Patrick", "Rick", "Steve", "Tom", "Vince",
             "Will", "Zach", "Ben", "Brian", "Colin", "Dan",
             "Edward", "Felix", "Gabe", "Greg", "Henry", "Jack", "Jeff",
             "Joe", "Josh", "Keith", "Kyle", "Matt", "Martin", "Max",
             "Mike", "Paul", "Phillip", "Toby", "Andrew", "Charles"];
var randomized_names = shuffle(names);
var num_names_used = 0;
function rand_name() {
  var random_name = randomized_names[num_names_used];
  num_names_used++
  return random_name;
}

var SanityTrial = function(with_block, side) {
  this.trial_type = "sanity"
  this.side = side;
  this.with_block = with_block;
  this.name = rand_name();
  this.correct = this.side == "left" ? 0 : 1;
    if (with_block == "performance") {
        this.left = "0th percentile";
        this.mid = "50th percentile";
        this.right = "99th percentile";
    var right_or_wrong = this.side == "left" ? "wrong" : "right";
    var better_or_worse = this.side == "left" ? "worse" : "better";
    this.prompt = this.name + " got every question " + right_or_wrong +
                  " on a math test and did " + better_or_worse +
                  " than everyone in his class. What score did " +
                  this.name + " get?";
    } else if (with_block == "improvement") {
        this.left = "gets a lot worse";
        this.mid = "stays the same";
        this.right = "improves a lot";
        var side_label = this.side == "left" ? this.left : this.right;
    this.prompt = this.name + " has some math ability, but that does't matter. Move the slider all the way to the " + this.side + " (" + side_label + ").";
  } else {
    console.log("ERROR 9");
  }
}

var Trial = function(trial_type, ability, effort, difficulty) {
  this.trial_type = trial_type;
  this.ability = ability;
  this.effort = effort;
  this.difficulty = difficulty;
  this.name = rand_name();
  if (trial_type == "performance") {
    //performance prompt
    this.prompt = this.name + " has <b>" + this.ability + "</b> math ability. </br> He puts <b>" +
                  this.effort + "</b> effort into " + article(this.difficulty) + " <b>" + this.difficulty +
                  "</b> math test.</br></br> What score does " + this.name + " get?";
    this.left = "0th percentile";
    this.mid = "50th percentile";
    this.right = "99th percentile";
  } else if (trial_type == "improvement") {
    this.prompt = this.name + " has <b>" + this.ability + "</b> math ability. </br> He puts <b>" +
                  this.effort + "</b> effort into doing some <b>" + this.difficulty +
                  "</b> practice problems.</br></br>  How much does " + this.name + "'s math ability improve after practicing?";
    this.left = "gets a lot worse";
    this.mid = "stays the same";
    this.right = "improves a lot";
  }
}

//<div id="slider0" class="slider">

var ability = ["high", "low"];
var effort = ["high", "medium", "minimal"];
var difficulty = ["difficult", "easy"];

var dweck_questions = [
                       "You have a certain amount of intelligence, and you really can't do much to change it",
                       "Your intelligence is something about you that you can't change very much",
                       "You can learn new things, but you can't really change your basic intelligence",
                       "Your intelligence can change, and how much it changes is within your control",
                       "You can learn new things, and that helps you change your intelligence",
                       "You can change your intelligence"
                       ];

/* trial types */
performance_trials = [ ]
improvement_trials = [ ]
//performance_sanity = [ ] //use these for excluding data
//improvement_sanity = [ ] //use these for not paying people (if they get both wrong, they don't get paid.

for  (var a=0; a<ability.length; a++) {
  for (var e=0; e<effort.length; e++) {
    for (var d=0; d<difficulty.length; d++) {
      performance_trials.push(new Trial("performance", ability[a], effort[e], difficulty[d]));
      improvement_trials.push(new Trial("improvement", ability[a], effort[e], difficulty[d]));
      //performance_trials.push(new SanityTrial("performance", "right"));
      //performance_trials.push(new SanityTrial("performance", "left"));
      //improvement_trials.push(new SanityTrial("improvement", "right"));
      //improvement_trials.push(new SanityTrial("improvement", "left"));
    }
  }
}
/*var performance_trials = get_combinations("performance", true, true);
var improvement_trials = get_combinations("improvement", true, true);
var dweck_questionnaire_trials = [{trial_type: "dweck_questionnaire"}];
var sanity_trials = [];

var mixed_section_trials = performance_trials
                                .concat(improvement_trials)
                                .concat(goal_trials)
                                .concat(failure_trials)
                                .concat(transfer_trials)
                                .concat(sanity_trials)*/

/* randomization */
var randomization = {
  names: randomized_names,
  performance: shuffle(performance_trials),
  improvement: shuffle(improvement_trials),
  block_order: shuffle(["performance", "improvement"])
 // prior_trials: shuffle(prior_trials),
  //mixed_section_trials: shuffle(mixed_section_trials),
  //dweck_questionnaire_trials: shuffle(dweck_questionnaire_trials),
  //acronym: sample(novel_acronyms)
}

all_trials = randomization[randomization.block_order[0]]
             .concat(randomization[randomization.block_order[1]])

/*console.log(all_trials.length);
console.log(names.length);*/

$(document).ready(function() {
  showSlide("consent");
  $("#mustaccept").hide();
  startTime = Date.now();
});

var experiment = {
  /*data: {
    "randomization": randomization
  },*/
  trial: function(trial_num) {
    $('.bar').css('width', ( (trial_num / all_trials.length)*100 + "%"));
    $(".err").hide();
    //get trial
    var mytrial = all_trials[trial_num];
    //var trial_type = trial_data.trial_type;
    //experiment[trial_type](trial_data);
    //console.log(trial_type);
      $(".left_label").html(mytrial.left);
      $(".right_label").html(mytrial.right);
    showSlide("trial");
    $(".continue").click(function() {
      $(".continue").unbind("click");
      if (trial_num + 1 < all_trials.length) {
        experiment.trial(trial_num + 1);
      } else {
        experiment.questionnaire();
      }
    });
    //var mytrial = new Trial("performance", "high", "minimal", "difficult")
    showSlide("trial");
    $(".prompt").html(mytrial.prompt)
  },
warning: function() {
    showSlide("warning");
    $(".continue").click(function() {
                         $(".continue").unbind("click");
                         experiment.intro();
                         })
},
  intro: function() {
    // var introduction = "Imagine that some people are taking a class where they're learning " +
    //                     introduce(randomization.domains[0]);
    // if (domains_per_S == 2) {
    //   introduction += " and some people are taking a class where they're learning " +
    //                     introduce(randomization.domains[1]);
    // } else if (domains_per_S == 3) {
    //   introduction += ", some people are taking a class where they're learning " +
    //                   introduce(randomization.domains[1]) +
    //                   ", and some people are taking a class where they're learning " +
    //                   introduce(randomization.domains[2])
    // }
    // var class_or_classes = "class";
    // if (domains_per_S > 1) {class_or_classes += "es"};
    // introduction += ".  We will give you some information about these people and about the " +
    //                 class_or_classes +
    //                 " and ask you to make some predictions.";
    showSlide("introduction");
    $(".continue").click(function() {
      $(".continue").unbind("click");
                         experiment.trial(0);
    });
  },
  dweck_questionnaire: function(trial_data) {
  },
  sanity: function(trial_data) {
    var rand_name = randomization.names[trial_data.name_index];
    var domain = mention(randomization.domains[trial_data.domain_index]);
    var ability = trial_data.ability;
    var difficulty = trial_data.difficulty;
    var effort = trial_data.effort;
    var prompt = rand_name + " has " + ability + " " + domain + " ability. He puts " +
      effort + " effort into some " + difficulty + " " + domain +
      " training. What is " + rand_name + "'s ability?";
    $(".prompt").html(prompt)
  },
  questionnaire: function() {
    //disable return key
    $(document).keypress( function(event){
     if (event.which == '13') {
        event.preventDefault();
      }
    });
    //progress bar complete
    $('.bar').css('width', ( "100%"));
    showSlide("questionaire");
    //submit to turk (using mmturkey)
    $("#formsubmit").click(function() {
      rawResponse = $("#questionaireform").serialize();
      pieces = rawResponse.split("&");
      var age = pieces[0].split("=")[1];
      var lang = pieces[1].split("=")[1];
      var comments = pieces[2].split("=")[1];
      if (lang.length > 0) {
        experiment.data["language"] = lang;
        experiment.data["comments"] = comments;
        experiment.data["age"] = age;
        var endTime = Date.now();
        experiment.data["duration"] = endTime - startTime;
        showSlide("finished");
        setTimeout(function() { turk.submit(experiment.data) }, 1000);
      }
    });
  }
}
