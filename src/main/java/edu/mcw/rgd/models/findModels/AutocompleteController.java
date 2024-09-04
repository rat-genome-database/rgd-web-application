package edu.mcw.rgd.models.findModels;

import com.google.gson.Gson;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.common.text.Text;
import org.elasticsearch.common.unit.Fuzziness;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.DisMaxQueryBuilder;
import org.elasticsearch.index.query.MultiMatchQueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.elasticsearch.search.fetch.subphase.highlight.HighlightBuilder;
import org.elasticsearch.search.fetch.subphase.highlight.HighlightField;
import org.elasticsearch.search.suggest.Suggest;
import org.elasticsearch.search.suggest.SuggestBuilder;
import org.elasticsearch.search.suggest.completion.CompletionSuggestionBuilder;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Created by jthota on 3/18/2020.
 */
public class AutocompleteController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        HttpRequestFacade req=new HttpRequestFacade(httpServletRequest);
        Set<String> autocompleteList=new HashSet<>();
        String term=req.getParameter("term");
        term = term.replaceAll("/", "\\/");
        String aspect=req.getParameter("aspect");

        CompletionSuggestionBuilder suggestionBuilder=new CompletionSuggestionBuilder("suggest");
        suggestionBuilder.text(term);
     //   suggestionBuilder.prefix(term, Fuzziness.TWO);
        suggestionBuilder.size(10000);
        SearchSourceBuilder srb=new SearchSourceBuilder();
        srb.suggest(new SuggestBuilder().addSuggestion("autocomplete-suggest", suggestionBuilder));

        SearchRequest searchRequest=new SearchRequest(RgdContext.getESIndexName("models"));
        searchRequest.source(srb);
        SearchResponse sr= ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);

        if(sr!=null){
            // Process the response
          sr.getSuggest().getSuggestion("autocomplete-suggest").getEntries().stream().map(Suggest.Suggestion.Entry::getOptions)
                  .forEach(options -> {
                      options.forEach(option -> {
                          autocompleteList.add(String.valueOf(option.getText()));
                      });
                  });

        }


        Gson gson = new Gson();
        String autoList = gson.toJson(autocompleteList);

        httpServletResponse.getWriter().write(autoList);
        return null;
    }
}
