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

var enough_responses;

var n_responses = 0;
responses = {};
function changeCreator(i) {
  return function(value) {
    $('#slider' + i).css({"background":"#99D6EB"});
    $('#slider' + i + ' .ui-slider-handle').css({
      "background":"#667D94",
      "border-color": "#001F29" });
    if (responses["response" + i] == null) {
      n_responses++;
      responses["response" + i] = [];
    }
    var slider_val = $("#slider"+i).slider("value");
    responses["response" + i] = slider_val;
  } 
}
function slideCreator(i) {
  return function() {
    $('#slider' + i + ' .ui-slider-handle').css({
       "background":"#E0F5FF",
       "border-color": "#001F29"
    });
  }
}

//var gender = ["male", "female", "mixed"];

var names = ["Adam", "Bob", "Carl", "Dave", "Evan", "Fred", "George",
             "Hank", "Ivan", "John", "Kevin", "Luke", "Mark", "Nick",
             "Oscar", "Patrick", "Rick", "Steve", "Tom", "Vince",
             "Will", "Zach", "Ben", "Brian", "Colin", "Dan",
             "Edward", "Felix", "Gabe", "Greg", "Henry", "Jack", "Jeff",
             "Joe", "Josh", "Keith", "Kyle", "Matt", "Martin", "Max",
             "Mike", "Paul", "Phillip", "Toby", "Andrew", "Charles"];

var dweck_questions = [
  "You have a certain amount of intelligence, and you can’t really do much to change it.",
  "Your intelligence is something about you that you can’t change very much.",
  "No matter who you are, you can significantly change your intelligence level.",
  "To be honest, you can’t really change how intelligent you are."
];

var goals = [
  "doing well on this test",
  "doing well on future tests",
  "being good at math",
  "improving at math",
  "showing his teacher that he has high math ability",
  "showing his teacher that he tries at math"
]

/* randomization */
var randomization = {
  dweck_questions: shuffle(dweck_questions),
  names: shuffle(names).slice(0,5),
  goals: shuffle(goals)
}

var nQs = 2;//dweck_questions.length + 1;

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
    $('.bar').css('width', ( (trial_num / nQs)*100 + "%"));
    $(".err").hide();
    var trial_type = trial_num == 0 ? "goals" : "dweck_questions";
    showSlide(trial_type);
    experiment[trial_type](randomization.names[trial_num]);
    $(".continue").click(function() {
      if (enough_responses()) {
        $(".continue").unbind("click");
        if (trial_num + 1 < nQs) {
          experiment.trial(trial_num + 1);
        } else {
          experiment.outgoing_questionnaire();
        }
      } else {
        $(".err").show();
      }
    });
  },
  goals: function(rand_name) {
    $(".prompt").html(rand_name + " is taking a test in this class. How much do you think he cares about each of the following things:");
    for (var i=0; i<randomization.goals.length; i++) {
      $("#ref" + i).html(randomization.goals[i]);
      responses["target" + i] = randomization.goals[i];
      $('#slider' + i).slider({
        animate: true,
        orientation: "horizontal",
        max: 1 , min: 0, step: 0.01, value: 0.5,
        slide: slideCreator(i),
        change: changeCreator(i)
      });
    }
    enough_responses = function() {
      return n_responses == randomization.goals.length;
    }
  },
  dweck_questions: function(trial_data) {
    for (var i=0; i<randomization.dweck_questions.length; i++) {
      $("#ref" + (6+i)).html(randomization.dweck_questions[i]);
      $('#slider' + (6+i)).slider({
        animate: true,
        orientation: "horizontal",
        max: 1 , min: 0, step: 0.01, value: 0.5,
        slide: slideCreator((6+i)),
        change: changeCreator((6+i))
      });
    }
    enough_responses = function() {
      return n_responses == randomization.goals.length + randomization.dweck_questions.length;
    }
  },
  outgoing_questionnaire: function() {
    //disable return key
    $(document).keypress( function(event){
     if (event.which == '13') {
        event.preventDefault();
      }
    });
    //progress bar complete
    $('.bar').css('width', ( "100%"));
    showSlide("outgoing_questionnaire");
    experiment.data["responses"] = responses;
    //submit to turk (using mmturkey)
    $("#formsubmit").click(function() {
      experiment.data["what_about"] = $("#what_about").val();
      experiment.data["comments"] = $("#comments").val();
      experiment.data["gender"] = $("#gender").val();
      experiment.data["heard_of"] = $("#heard_of").val();
      experiment.data["hear_more"] = $("#hear_more").val();
      var endTime = Date.now();
      experiment.data["duration"] = endTime - startTime;
      showSlide("finished");
      setTimeout(function() { turk.submit(experiment.data) }, 1000);
    });
  }
}