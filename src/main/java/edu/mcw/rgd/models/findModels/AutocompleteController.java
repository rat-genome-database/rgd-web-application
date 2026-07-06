package edu.mcw.rgd.models.findModels;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.CompletionSuggestOption;
import co.elastic.clients.elasticsearch.core.search.Suggestion;
import com.google.gson.Gson;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.*;

public class AutocompleteController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(httpServletRequest);
        Set<String> autocompleteList = new HashSet<>();
        String term = req.getParameter("term");
        term = term.replaceAll("/", "\\/");

        final String termF = term;
        ElasticsearchClient client = ClientInit.getClient();
        SearchResponse<Map> sr = client.search(s -> s
                        .index(RgdContext.getESIndexName("models"))
                        .suggest(sg -> sg
                                .text(termF)
                                .suggesters("autocomplete-suggest", su -> su
                                        .completion(c -> c.field("suggest").size(10000)))),
                Map.class);

        if (sr != null && sr.suggest() != null) {
            List<Suggestion<Map>> suggestions = sr.suggest().get("autocomplete-suggest");
            if (suggestions != null) {
                for (Suggestion<Map> suggestion : suggestions) {
                    if (suggestion.isCompletion()) {
                        for (CompletionSuggestOption<Map> option : suggestion.completion().options()) {
                            autocompleteList.add(String.valueOf(option.text()));
                        }
                    }
                }
            }
        }


        Gson gson = new Gson();
        String autoList = gson.toJson(autocompleteList);

        httpServletResponse.getWriter().write(autoList);
        return null;
    }
}
