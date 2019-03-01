<div class="modal fade" id="myModal">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">

            <div class="modal-header">
                <a @click="explore(geneData.genes);" href="javascript:void(0);">Explore this Gene Set</a>
            </div>
            <!-- Modal body -->
            <div class="modal-body">
                <div v-if="geneLoading">Loading...</div>
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