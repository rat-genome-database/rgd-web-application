<div class="row"  style="margin-left: 10px">

        <div class="card">
            <article class="card-group-item">
                <header class="card-header">
                    <h6 class="title">Clinical Measurements </h6>
                </header>
                <div class="filter-content">
                    <div class="card-body">
                        <div   ng-class-odd="'oddRow'" ng-class-even="'evenRow'"   ng-repeat="measurement in rootMeasurements"  >

                            <label class="form-check">
                                <input class="form-check-input" type="radio" name="cmoRadio" ng-value="measurement"
                                       ng-model="selectedMeasurement" ng-checked="measurement.checked" ng-click='changeCMO(measurement)'>&nbsp;
                                <span class="form-check-label" >{{measurement.term}}</span>
                            </label>
                        </div>
                    </div> <!-- card-body.// -->
                </div>
            </article> <!-- card-group-item.// -->
            <article class="card-group-item">
                <header class="card-header">
                    <h6 class="title">Samples </h6>
                </header>
                <div class="filter-content">
                    <div class="card-body " style="overflow-x: auto">
                        <form>
                            <div  ng-class-odd="'oddRow'" ng-class-even="'evenRow'" ng-repeat="sample in samples"  >

                                <label class="form-check">
                                    <input class="form-check-input" type="checkbox" name="selectedSamples"  ng-model="selectedSamples" ng-checked="sample.checked" ng-value="sample"
                                    ng-click="loadSelectedSample()">&nbsp;
                                    <span class="form-check-label">{{sample.term}}</span>
                                </label> <!-- form-check.// -->
                            </div>
                        </form>
                    </div> <!-- card-body.// -->
                </div>
            </article> <!-- card-group-item.// -->


            <article class="card-group-item">
                <header class="card-header">
                    <h6 class="title">Measurement Methods </h6>
                </header>
                <div class="filter-content">
                    <div class="card-body overflow-auto">
                        <form>
                            <div  ng-class-odd="'oddRow'" ng-class-even="'evenRow'" name="measurementCheck" ng-repeat="method in methods">

                                <label class="form-check">
                                    <input class="form-check-input" type="checkbox" value="" checked>&nbsp;
                                    <span class="form-check-label" > {{method.term}}</span>
                                </label> <!-- form-check.// -->
                            </div>

                        </form>
                    </div> <!-- card-body.// -->
                </div>
            </article> <!-- card-group-item.// -->
            <article class="card-group-item">
                <header class="card-header">
                    <h6 class="title">Conditions </h6>
                </header>
                <div class="filter-content">
                    <div class="card-body overflow-auto">
                        <form>
                            <div  ng-class-odd="'oddRow'" ng-class-even="'evenRow'" name="condtionCheck" ng-repeat="condition in conditionSet">

                                <div ng-repeat="cond in condition" g-class-odd="'oddRow'" g-class-even="'evenRow'" style="margin-bottom:5px;">
                                    <label class="form-check">
                                    <input class="form-check-input" type="checkbox" value="" checked>&nbsp;
                                    <span class="form-check-label" style="color:{{colors[$index]}}" checked>{{ cond }}</span>
                                    </label> <!-- form-check.// -->
                                </div>
                            </div>
                        </form>
                    </div> <!-- card-body.// -->
                </div>
            </article> <!-- card-group-item.// -->
            <article class="card-group-item">
                <header class="card-header">
                    <h6 class="title">Age </h6>
                </header>
                <div class="filter-content">
                    <div class="card-body">
                        <form>
                                <div  ng-class-odd="'oddRow'" ng-class-even="'evenRow'" ng-repeat="ageRange in ageRanges">

                                <label class="form-check">
                                    <input class="form-check-input" type="checkbox" value="" checked>&nbsp;
                                    <span class="form-check-label">  {{ageRange}}</span>
                                </label> <!-- form-check.// -->
                            </div>

                        </form>
                    </div> <!-- card-body.// -->
                </div>
            </article>
        </div> <!-- card.// -->




</div>

