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

function article(difficulty) {
  return difficulty == "easy" ? "an" : "a";
}

var names = ["Adam", "Bob", "Carl", "Dave", "Evan", "Fred", "George",
             "Hank", "Ivan", "John", "Kevin", "Luke", "Mark", "Nick",
             "Oscar", "Patrick", "Rick", "Steve", "Tom", "Vince",
             "Will", "Zach", "Ben", "Brian", "Colin", "Dan",
             "Edward", "Felix", "Gabe", "Greg", "Henry", "Jack", "Jeff",
             "Joe", "Josh", "Keith", "Kyle", "Matt", "Martin", "Max",
             "Mike", "Paul", "Phillip", "Toby", "Andrew", "Charles"];

//<div id="slider0" class="slider">

var ability = ["high", "low"];
var effort = ["high", "medium", "minimal"];
var difficulty = ["difficult", "easy"];

/* trial types */
var performance_combos = [];
var improvement_combos = [];
var performance_sanity = [
  {type:"sanity", correct:0},
  {type:"sanity", correct:1}
];

for  (var a=0; a<ability.length; a++) {
  for (var e=0; e<effort.length; e++) {
    for (var d=0; d<difficulty.length; d++) {
      performance_combos.push({
        type:"performance",
        ability:ability[a],
        effort:effort[e],
        difficulty:difficulty[d]
      });
      improvement_combos.push({
        type:"improvement",
        ability:ability[a],
        effort:effort[e],
        difficulty:difficulty[d]
      });
    }
  }
}

var randomization = {
  names: shuffle(names),
  slider_trials: shuffle([0, 6, 10]),
  performance_trials: shuffle(shuffle(performance_combos).slice(0,6).concat(performance_sanity)),
  improvement_trials: shuffle(improvement_combos).slice(0,6),
  block_order: shuffle(["performance", "improvement"])
}

n_trials = randomization.slider_trials.length +
           randomization.performance_trials.length +
           randomization.improvement_trials.length +
           1 //dweck

// WHERE ARE WE IN THE EXPERIMENT?
n_trials_completed = 0;
n_performance_trials_completed = 0;
n_improvement_trials_completed = 0;
n_slider_trials_completed = 0;

$(document).ready(function() {
  showSlide("consent");
  $("#mustaccept").hide();
  startTime = Date.now();
});

var experiment = {
  data: {
    "randomization": randomization
  },
  intro: function() {
    showSlide("introduction");
    $(".continue").click(function() {
      $(".continue").unbind("click");
      experiment.slider_practice_intro();
    });
  },
  slider_practice_intro: function() {
    showSlide("slider_practice_intro");
    $(".continue").click(function() {
      $(".continue").unbind("click");
      experiment.slider_practice();
    });
  },
  slider_practice: function() {
    showSlide("slider_practice");
    //how many out of 10:
    var how_many_target = randomization.slider_trials[n_slider_trials_completed];
    $("#slider_practice_number").html(how_many_target + "/10");
    $(".continue").click(function() {
      $(".continue").unbind("click");
      if (true) {
        //check for slider data here
        n_slider_trials_completed++;
        if (n_slider_trials_completed < randomization.slider_trials.length) {
          //if more slider trials, keep going
          experiment.slider_practice();
        } else {
          //else start whatever experiment block is randomized to be first.
          experiment[randomization.block_order[0] + "_intro"]();
        }
      } else {
        $(".err").show();
      }
    });
  },
  performance_intro: function() {
    showSlide("performance_intro");
    var first_or_next = randomization.block_order[0] == "performance" ? "First" : "Next"
    $(".prompt").html(first_or_next + ", we will ask you about people's performance on some tests in this class.");
    $(".continue").click(function() {
      $(".continue").unbind("click");
      experiment.performance();
    })
  },
  performance: function() {
    $('.bar').css('width', ( (n_trials_completed / n_trials)*100 + "%"));
    $(".err").hide();
    showSlide("performance");
    var trial_data = randomization.performance_trials[n_performance_trials_completed];
    if (trial_data.type == "sanity") {
      $(".prompt").html(trial_data.correct);
    } else {
      $(".prompt").html(trial_data.ability + " " + trial_data.effort + " " + trial_data.difficulty);
    }
    $(".continue").click(function() {
      $(".continue").unbind("click");
      n_performance_trials_completed++;
      if (n_performance_trials_completed < randomization.performance_trials.length) {
        experiment.performance();
      } else if (n_improvement_trials_completed == 0) {
        experiment.improvement_intro();
      } else {
        experiment.dweck_questionnaire();
      }
    });
  },
  improvement_intro: function() {
    showSlide("improvement_intro");
    var first_or_next = randomization.block_order[0] == "improvement" ? "First" : "Next"
    $(".prompt").html(first_or_next + ", we will ask you about people's improvement as they practice.");
    $(".continue").click(function() {
      $(".continue").unbind("click");
      experiment.improvement();
    })
  },
  improvement: function() {
    $('.bar').css('width', ( (n_trials_completed / n_trials)*100 + "%"));
    $(".err").hide();
    var trial_data = randomization.improvement_trials[n_improvement_trials_completed];
    $(".prompt").html(trial_data.ability + trial_data.effort + trial_data.difficulty);
    showSlide("improvement");
    $(".continue").click(function() {
      $(".continue").unbind("click");
      n_improvement_trials_completed++;
      if (n_improvement_trials_completed < randomization.improvement_trials.length) {
        experiment.improvement();
      } else if (n_performance_trials_completed == 0) {
        experiment.performance_intro();
      } else {
        experiment.dweck_questionnaire();
      }
    });
  },
  dweck_questionnaire: function() {
    showSlide("dweck_questionnaire");
    $(".continue").click(function() {
      $(".continue").unbind("click");
      experiment.questionnaire();
    })
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
    showSlide("questionnaire");
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
