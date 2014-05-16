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

/* possible values */
var domains = ["math", "typing", "NOVEL"];
var novel_acronyms = ["TGPL", "GROX", "QSRT", "VBRA"];
var names = ["Adam", "Bob", "Carl", "Dave", "Evan", "Fred", "George",
             "Hank", "Ivan", "John", "Kevin", "Luke", "Mark", "Nick",
             "Oscar", "Patrick", "Rick", "Steve", "Tom", "Vince",
             "Will", "Zach", "Ben", "Brian", "Colin", "Dan",
             "Edward", "Felix", "Gabe", "Greg", "Henry", "Jack", "Jeff",
             "Joe", "Josh", "Keith", "Kyle", "Matt", "Martin", "Max",
             "Mike", "Paul", "Phillip", "Toby", "Andrew", "Charles",
             "A", "B", "D", "C", "E", "F", "G", "H", "I", "J", "K"];
var ability = ["high", "medium", "low"];
var effort = ["high", "medium", "no"];
var difficulty = ["difficult", "easy"];

/* parameters for experiment */
var domains_per_S = 1; //or domains.length for within Ss

/* trial types */
var name_index = 0;
function get_combinations(trial_type, combinate_arguments, combinate_ability) {
  var combinations = [];
  if (combinate_arguments) {
    for (var domain_index=0; domain_index<domains_per_S; domain_index++) {
      for (var e=0; e<effort.length; e++) {
        for (var d=0; d<difficulty.length; d++) {
          if (combinate_ability) {
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
          } else {
            combinations.push({
              trial_type: trial_type,
              domain_index: domain_index,
              effort: effort[e],
              difficulty: difficulty[d],
              name_index: name_index
            });
            name_index += 1;
          }
        }
      }
    }
  } else {
    for (var domain_index=0; domain_index<domains_per_S; domain_index++) {
      combinations.push({
        trial_type: trial_type,
        domain_index: domain_index,
        name_index: name_index
      });
      name_index += 1;
    }
  }
  return(combinations);
}
var prior_trials = get_combinations("prior", false, false);
var performance_trials = get_combinations("performance", true, true);
var improvement_trials = get_combinations("improvement", true, true);
var goal_trials = get_combinations("goals", false, false);
var failure_trials = get_combinations("goals", false, false);
var transfer_trials = get_combinations("improvement_transfer", true, true);
var dweck_questionnaire_trials = [{trial_type: "dweck_questionnaire"}];
var sanity_trials = [];

var mixed_section_trials = performance_trials
                                .concat(improvement_trials)
                                .concat(goal_trials)
                                .concat(failure_trials)
                                .concat(transfer_trials)
                                .concat(sanity_trials)

/* randomization */
var randomization = {
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
console.log(names.length);

function introduce(domain) {
  if (domain == "NOVEL") {
    return("a new thing called " + randomization.acronym);
  } else {
    return(domain);
  }
}

function mention(domain) {
  if (domain == "NOVEL") {
    return(randomization.acronym);
  } else {
    return(domain);
  }
}

$(document).ready(function() {
  showSlide("consent");
  $("#mustaccept").hide();
  startTime = Date.now();
});

var experiment = {
  data: {
    "randomization": randomization
  },
  trial: function(trial_num) {
    $('.bar').css('width', ( (trial_num / all_trials.length)*100 + "%"));
    $(".err").hide();
    //get trial
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
    });
  },
  intro: function() {
    var introduction = "Imagine that some people are taking a class where they're learning " +
                        introduce(randomization.domains[0]);
    if (domains_per_S == 2) {
      introduction += " and some people are taking a class where they're learning " +
                        introduce(randomization.domains[1]);
    } else if (domains_per_S == 3) {
      introduction += ", some people are taking a class where they're learning " +
                      introduce(randomization.domains[1]) +
                      ", and some people are taking a class where they're learning " +
                      introduce(randomization.domains[2])
    }
    var class_or_classes = "class";
    if (domains_per_S > 1) {class_or_classes += "es"};
    introduction += ".  We will give you some information about these people and about the " +
                    class_or_classes +
                    " and ask you to make some predictions.";
    $("#introduction").html(introduction);
    showSlide("intro");
    $(".continue").click(function() {
      $(".continue").unbind("click");
      experiment.trial(0)
    });
  },
  prior: function(trial_data) {
    var rand_name = randomization.names[trial_data.name_index];
    var domain = randomization.domains[trial_data.domain_index];
    $(".prompt").html("Please tell us how likely you think it is that " +
      rand_name + " has the following levels of " + mention(domain) +
      " ability:")
    $(".slider_container").html(
      '<table><tbody><tr><td>high</td>' +
      '<td><div class="slider" id="slider_high"></div></td></tr>' +
      '<tr><td>medium</td>' +
      '<td><div class="slider" id="slider_medium"></div></td></tr>' +
      '<tr><td>low</td>' +
      '<td><div class="slider" id="slider_low"></div></td></tr></tbody></table>'
    );
    $("#slider_high").slider({
      animate: true,
      orientation: "horizontal",
      max: 100 , min: 0, step: 1, value: 50,
      slide: function() {
        $('#slider_high .ui-slider-handle').css({
           "background":"#E0F5FF",
           "border-color": "#001F29"
        });
      },
      change: function(value) {
        $('#slider' + i).css({"background":"#99D6EB"});
        $('#slider' + i + ' .ui-slider-handle').css({
          "background":"#667D94",
          "border-color": "#001F29" });
        if (trialData.responses[i] == null) {
          nResponses++;
        }
        var sliderVal = $("#slider"+i).slider("value");
        //trialData.responses[i] = sliderVal;
        //$("#slider" + i + "val").html(sliderVal);
      }
    });
  },
  performance: function(trial_data) {
    var rand_name = randomization.names[trial_data.name_index];
    var domain = mention(randomization.domains[trial_data.domain_index]);
    var ability = trial_data.ability
    var difficulty = trial_data.difficulty;
    var effort = trial_data.effort;
    $(".prompt").html(
      rand_name + " has " + ability + " " + domain + " ability. He puts " +
      effort + " effort into a " + difficulty + " test. What score does " +
      rand_name + " get?"
    )
  },
  improvement: function(trial_data) {
    var rand_name = randomization.names[trial_data.name_index];
    var domain = mention(randomization.domains[trial_data.domain_index]);
    var ability = trial_data.ability;
    var difficulty = trial_data.difficulty;
    var effort = trial_data.effort;
    $(".prompt").html(
      rand_name + " has " + ability + " " + domain + " ability. He puts " +
      effort + " effort into some " + difficulty + " " + domain +
      " training. How much does " + rand_name + " " + domain +
      "'s ability improve after training?"
    )
  },
  goals: function(trial_data) {
    var rand_name = randomization.names[trial_data.name_index];
    var domain = mention(randomization.domains[trial_data.domain_index]);
    $(".prompt").html(
      rand_name + " is taking a " + domain +
      " test. Please tell us how much you think he cares about each of the following things:"
    )
  },
  improvement_transfer: function(trial_data) {
    var rand_name = randomization.names[trial_data.name_index];
    var domain = mention(randomization.domains[trial_data.domain_index]);
    var ability = trial_data.ability;
    var difficulty = trial_data.difficulty;
    var effort = trial_data.effort;
    $(".prompt").html(
      rand_name + " has " + ability + " " + domain + " ability. He puts " +
      effort + " effort into some " + difficulty + " " + domain +
      " training. How much does " + rand_name +
      " intelligence improve after training?"
    )
  },
  failure: function(trial_data) {
    var rand_name = randomization.names[trial_data.name_index];
    var domain = mention(randomization.domains[trial_data.domain_index]);
    $(".prompt").html(
      "A passing grade is 50%. " + rand_name + " gets 5% in a " + domain +
      " test. Please rate how much you agree with following statements:"
    )
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