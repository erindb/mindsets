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

var Trial = function(trial_type, ability, effort, difficulty, rand_name) {
  this.trial_type = trial_type
  this.ability = ability
  this.effort = effort
  this.difficulty = difficulty
  this.name = rand_name
  this.prompt = ""
  this.left = ""
  this.right = ""
  this.mid = ""
  this.lower = 0
  this.upper = 1
  if (trial_type == "sanity") {
    //sanity prompt
    this.prompt = this.name + " got every question right on a math test and did better than everyone in his class. What score did " + this.name + " get?"
    this.left = "0th percentile"
    this.mid = "50th percentile"
    this.right = "99th percentile"
  } else if (trial_type == "performance") {
    //performance prompt
    this.prompt = this.name + " has " + this.ability + " math ability. He puts " +
                  this.effort + " into " + article(this.difficulty) + " " + this.difficulty +
                  " math test. What score does " + this.name + " get?"
    this.left = "0th percentile"
    this.mid = "50th percentile"
    this.right = "99th percentile"
  } else if (trial_type == "improvement") {
    this.prompt = this.name + " has " + this.ability + " math ability. He puts " +
                  this.effort + " into some " + this.difficulty +
                  " training. How much does " + this.name + "'s math ability improve after training?"
    this.left = "gets a lot worse"
    this.mid = "stays the same"
    this.right = "improves a lot"
    this.lower = -1
    this.upper = 1
  }
}

//<div id="slider0" class="slider">

var names = ["Adam", "Bob", "Carl", "Dave", "Evan", "Fred", "George",
             "Hank", "Ivan", "John", "Kevin", "Luke", "Mark", "Nick",
             "Oscar", "Patrick", "Rick", "Steve", "Tom", "Vince",
             "Will", "Zach", "Ben", "Brian", "Colin", "Dan",
             "Edward", "Felix", "Gabe", "Greg", "Henry", "Jack", "Jeff",
             "Joe", "Josh", "Keith", "Kyle", "Matt", "Martin", "Max",
             "Mike", "Paul", "Phillip", "Toby", "Andrew", "Charles"];
var ability = ["high", "low"];
var effort = ["high", "medium", "minimal"];
var difficulty = ["difficult", "easy"];

/* trial types */
/*var name_index = 0;
function get_combinations(trial_type) {
  var combinations = [];
  for (var domain_index=0; domain_index<domains_per_S; domain_index++) {
    for (var e=0; e<effort.length; e++) {
      for (var d=0; d<difficulty.length; d++) {
        for (var a=0; a<ability.length; a++) {
          combinations.push({
            trial_type: trial_type,
            domain_index: domain_index,
            ability: ability[a],
            effort: effort[e],
            difficulty: difficulty[d],
            name_index: name_index
          });
          name_index += 1;
        }
      }
    }
  }
  return(combinations);
}
var performance_trials = get_combinations("performance", true, true);
var improvement_trials = get_combinations("improvement", true, true);
var dweck_questionnaire_trials = [{trial_type: "dweck_questionnaire"}];
var sanity_trials = [];

var mixed_section_trials = performance_trials
                                .concat(improvement_trials)
                                .concat(goal_trials)
                                .concat(failure_trials)
                                .concat(transfer_trials)
                                .concat(sanity_trials)

/* randomization */
/*var randomization = {
  domains: shuffle(sample_n(domains, domains_per_S)),
  names: shuffle(names),
  prior_trials: shuffle(prior_trials),
  mixed_section_trials: shuffle(mixed_section_trials),
  dweck_questionnaire_trials: shuffle(dweck_questionnaire_trials),
  acronym: sample(novel_acronyms)
}
all_trials = randomization.prior_trials
             .concat(randomization.mixed_section_trials)
             .concat(randomization.dweck_questionnaire_trials)

console.log(all_trials.length);
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
    //$('.bar').css('width', ( (trial_num / all_trials.length)*100 + "%"));
    $(".err").hide();
    /*//get trial
    var trial_data = all_trials[trial_num];
    var trial_type = trial_data.trial_type;
    experiment[trial_type](trial_data);
    console.log(trial_type);
    showSlide(trial_type);
    $(".continue").click(function() {
      $(".continue").unbind("click");
      if (trial_num + 1 < all_trials.length) {
        experiment.trial(trial_num + 1);
      } else {
        experiment.questionnaire();
      }
    });*/
    var mytrial = new Trial("sanity", "high", "minimal", "difficult", "Bob")
    showSlide("trial");
    $(".prompt").html(mytrial.prompt)

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
    // $("#introduction").html(introduction);
    showSlide("intro");
    $(".continue").click(function() {
      $(".continue").unbind("click");
      experiment.trial(0)
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