# LOEP (Learning Object Evaluation Platform)

LOEP is an open source web-based platform developed using Ruby on Rails that aims to facilitate the evaluation of small and self-contained web educational resources, known as Learning Objects, in different scenarios and educational contexts. It has been designed to provide systematic evaluation of Learning Objects and generation of quality scores to e-Learning systems according to multiple evaluation models and quality metrics. LOEP provides several features including user and Learning Object management, Learning Object evaluations tools, review assignments, interoperability with e-Learning systems, and statistics.

LOEP can provide Learning Object evaluation to e-Learning systems in an open, low cost, reliable and effective way.
Repositories of educational resources can use LOEP to implement quality control policies and to enhance search services and recommender systems. 

The last releases can be seen [here](https://github.com/agordillo/LOEP/releases), and the future features and ongoing developments are shown on this [page](https://github.com/agordillo/LOEP/milestones).  
  
  
# Features and components
  
* User management supporting several roles:
  * SuperAdmin
  * Admin
  * Reviewer
  * Regular User
* User Interface
  * For admins: administration of the platform.
  * For reviewers: access to evaluation tools and training materials.
  * For third-party e-Learning systems. LOEP provide evaluation forms that can be integrated in the external e-Learning systems. 
* Learning Object management
  * Registration and edition
  * Ranking
  * Search
* LOM (Learning Object Metadata) support, and quality metrics based on LOM
* Assignments: appoint reviewers to evaluate Learning Objects
  * Manually
  * Automatically using differeht matching stategies:
    * Prioritize workload balancing with random matching 
    * Prioritize workload balancing with best-effort matching
    * Prioritize reviewer suitability
* Support of several Learning Object evaluation models (as well as general purpose evaluation models)
  * LORI (Learning Object Review Instrument)
  * LOEM (Learning Object Evaluation Metric)
  * SUS (System Usability Scale)
  * WBLT-S (WBLT Evaluation Scale for Students)
  * WBLT-T (WBLT Evaluation Scale for Teachers)
  * UNE 71362: Teacher profile and student profile
  * Metadata Quality evaluation model (automatic)
  * Interaction Quality evaluation model (automatic)
* Support for automatic evaluation models and human reviews
* Support of several Learning Object quality metrics (as well as general purpose quality metrics)
  * AM (Arithmetic Mean) Metric for all evaluation models
  * WAM (Weighted Arithmetic Mean) Metric for all evaluation models
  * Additional metrics for LORI: Pedagogical, Technical, Orthogonal, Logarithmic, Square Root, ...
  * SUS (System Usability Scale) score
  * Metadata Quality metrics: Overall metadata quality, Completeness, Coherence, Conformance, Consistency and Findability.
  * Interaction Quality metric
* Support for defining and adding new evaluation models
* Support for defining and adding new quality metrics  
* Support for public and private plugins
* Evaluation reports, scores, statistics and graphs
* Evaluations and reports can be exported to excel files
* Learning Object Quality comparison and aggregated statistics
* API for connecting LOEP with e-Learning systems:
  * Learning Object API: allows to register, update and delete Learning Objects.
  * LOEP Callback API: allows the e-Learning systems to be notified of updates on the Learning Objects (new evaluations, updates of quality scores, ...).
  * LOEP Session Token API: allows third-party applications to generate session tokens that can be later used for different actions such as embedding evaluation web forms and showing results of evaluations through charts.
* The same LOEP instance can be used to provide systematic evaluation to several e-Learning systems (with some constraints).

# Requirements:  

* Ruby 2.0 or newer
* Ruby on Rails 3.2.22
* MySQL 5.5+


# Discussion and contribution  
  
Feel free to raise an issue at [github](http://github.com/agordillo/LOEP/issues).  


# News

Follow the LOEP news on the [blog](https://loepblog.wordpress.com/). 


# Installation and documentation

Do you want to install LOEP for development purposes? <br/>
Do you want to use LOEP in your project? <br/>
Do you want to deploy your own LOEP istance? <br/>
Are you looking to contribute to this open source project?  <br/>
Are you interested in learning how to use the LOEP APIs or how to set up a LOEP instance? <br/>

Visit our [wiki](http://github.com/agordillo/LOEP/wiki) to see all the available documentation.  



# Copyright

© Universidad Politécnica de Madrid, 2019  
Aldo Gordillo Méndez, Enrique Barra Arias

LOEP is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

LOEP is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with LOEP. If not, see [http://www.gnu.org/licenses](http://www.gnu.org/licenses).
