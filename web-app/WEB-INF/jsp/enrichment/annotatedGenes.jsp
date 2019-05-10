<div class="modal fade" id="myModal">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <div class="modal-header">
                <a @click="explore(geneData.genes);" href="javascript:void(0);">Explore this Gene Set</a>
            </div>
            <!-- Modal body -->
            <div class="modal-body">
                <div v-if="geneLoading">Loading... This May take a bit ...

                    <div class="spinner-border text-primary" role="status">
                        <span class="sr-only">Loading...</span>
                    </div>
                    <div class="spinner-border text-secondary" role="status">
                        <span class="sr-only">Loading...</span>
                    </div>
                    <div class="spinner-border text-success" role="status">
                        <span class="sr-only">Loading...</span>
                    </div>
                    <div class="spinner-border text-danger" role="status">
                        <span class="sr-only">Loading...</span>
                    </div>
                    <div class="spinner-border text-warning" role="status">
                        <span class="sr-only">Loading...</span>
                    </div>

                    <br>
                </div>
                <table class="table table-striped">
                    <tr
                            v-for="data in geneData.geneData"
                            class="data"
                    >
                        <td>{{data.gene}}</td>
                        <td>{{data.terms}}</td>
                    </tr>
                </table>
            </div>

            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
            </div>

        </div>
    </div>
</div>