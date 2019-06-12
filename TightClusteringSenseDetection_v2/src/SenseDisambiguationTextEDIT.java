package MetaMapWrapper;

import SenseDetection.Stemmer;
import java.util.Vector;
// import java.io.FileWriter;
import java.io.IOException;
// import java.io.FileNotFoundException;
import java.io.Reader;
import java.io.BufferedReader;
import java.io.InputStreamReader; 
// import java.io.FileReader;
// import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class SenseDisambiguationText
{
    public static int WINDOW_SIZE;
    Map<String, String> sense_cui_map;
    Map<String, String> sense_semantic_map;
    Map<String, AbbrProfile> abbr_profile_map;
    FeatureDB feature_db;
    SentenceBoundary sb;
    
    static {
        SenseDisambiguationText.WINDOW_SIZE = 6;
    }
    
    public SenseDisambiguationText() {
        this.sense_cui_map = new HashMap<String, String>();
        this.sense_semantic_map = new HashMap<String, String>();
        this.abbr_profile_map = new HashMap<String, AbbrProfile>();
        this.feature_db = new FeatureDB();
    }
    
    public int load_profile(final String profile_dir) {
        final File indir = new File(profile_dir);
        File[] listFiles;
        for (int length = (listFiles = indir.listFiles()).length, i = 0; i < length; ++i) {
            final File infile = listFiles[i];
            final String filename = infile.getName();
            if (filename.indexOf(".") != 0) {
                final AbbrProfile profile = new AbbrProfile(filename, this.feature_db);
                profile.load(String.valueOf(profile_dir) + "//" + filename);
                this.abbr_profile_map.put(filename, profile);
            }
        }
        return 0;
    }
    
    public int load_sense_cui(final String inventory_file) {
        try {
            final BufferedReader infile = new BufferedReader(new FileReader(inventory_file));
            String line = "";
            while ((line = infile.readLine()) != null) {
                final String[] splitline = line.trim().split("\t");
                final String abbr = splitline[0];
                final String sense = splitline[1];
                final String cui = splitline[3];
                final String semantic = splitline[5];
                final String key = String.valueOf(abbr) + "\t" + sense;
                this.sense_cui_map.put(key, cui.toUpperCase());
                this.sense_semantic_map.put(key, semantic);
            }
            infile.close();
        }
        catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        catch (IOException e2) {
            e2.printStackTrace();
        }
        return 0;
    }
    
    public int parse_dir(final String indirname, final String outdirname) {
        final File indir = new File(indirname);
        File[] listFiles;
        for (int length = (listFiles = indir.listFiles()).length, i = 0; i < length; ++i) {
            final File infile = listFiles[i];
            final String filename = infile.getName();
            if (filename.indexOf(".") != 0) {
                final String infilename = String.valueOf(indirname) + "//" + filename;
                final String outfilename = String.valueOf(outdirname) + "//" + filename;
                System.out.println(infilename);
                this.parse_file(infilename, outfilename);
            }
        }
        return 0;
    }
    
    public int parse_input(final String infilename, final String outfilename) {
        try {
            final BufferedReader infile = new BufferedReader(new FileReader(infilename));
        	// final Scanner infile = new Scanner(System.in);
        	
        	
        	// THIS ISN"T GOING TO WORK BECAUSE IT DOESN'T ACKNOWLEDGE THE DATA COMING IN
        	// final BufferedReader infile = new BufferedReader(new InputStreamReader(System.in));
            String content = "";
            String line = "";
            while ((line = infile.readLine()) != null) {
                content = String.valueOf(content) + line + "\n";
            }
            final Document doc = new Document(content, infilename);
            this.sb.detect_boundaries(doc);
            doc.break_long_sentence();
            String ret = "";
            String[] split;
            for (int length = (split = doc.boundary_norm_str().split("\n")).length, i = 0; i < length; ++i) {
                final String sentence = split[i];
                ret = String.valueOf(ret) + "Sentence=" + sentence + "\n";
                ret = String.valueOf(ret) + this.parse_sentence(sentence);
                ret = String.valueOf(ret) + "\n";
                // see if this will print what I expect to console
                System.out.print(ret);
            }
            // NEED TO HANDLE FILE GOING OUT TOO (should be a strategically placed
            // System.out.println
            
            infile.close();
            final FileWriter outfile = new FileWriter(outfilename);
            // outfile.write(ret);
            outfile.close();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public String parse_sentence(final String sentencestr) {
        String ret = "";
        int start = 0;
        int end = 0;
        String cursentence = sentencestr;
        String[] split;
        for (int length = (split = sentencestr.split(" ")).length, j = 0; j < length; ++j) {
            final String token = split[j];
            start = end + cursentence.indexOf(token);
            end = start + token.length();
            cursentence = sentencestr.substring(end);
            final String purified = this.purify(token);
            if (this.abbr_profile_map.containsKey(purified)) {
                final String lsent = sentencestr.substring(0, start);
                String rsent = "";
                if (end < sentencestr.length()) {
                    rsent = sentencestr.substring(end + 1);
                }
                final String[] ltoken = purify_token(lsent);
                final String[] rtoken = purify_token(rsent);
                final AbbrItem item = new AbbrItem(purified, "", lsent, rsent);
                for (int i = 1; i <= SenseDisambiguationText.WINDOW_SIZE && ltoken.length - i >= 0; ++i) {
                    final String word = ltoken[ltoken.length - i];
                    item.add_context(-i, word);
                }
                for (int i = 1; i <= SenseDisambiguationText.WINDOW_SIZE && i - 1 < rtoken.length; ++i) {
                    final String word = rtoken[i - 1];
                    item.add_context(i, word);
                }
                final Map<String, Integer> feature_tf_map = item.get_feature_tf();
                final AbbrProfile profile = this.abbr_profile_map.get(purified);
                final String sense = profile.get_sense(feature_tf_map);
                String cui = "NONE";
                String semantic = "NONE";
                if (this.sense_cui_map.containsKey(String.valueOf(purified) + "\t" + sense)) {
                    cui = this.sense_cui_map.get(String.valueOf(purified) + "\t" + sense);
                    semantic = this.sense_semantic_map.get(String.valueOf(purified) + "\t" + sense);
                }
                ret = String.valueOf(ret) + "Abbr:\t" + token + "\t" + purified + "\t" + sense + "\t" + cui + "\t" + semantic + "\n";
            }
        }
        return ret;
    }
    
    public String purify(final String token) {
        String purified = "";
        for (int i = 0; i < token.length(); ++i) {
            final char c = token.charAt(i);
            if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '\'') {
                purified = String.valueOf(purified) + c;
            }
        }
        return purified.toLowerCase();
    }
    
    private static String[] purify_token(String lsent) {
        final String removed_char = ", : ; ? ! ) ( < > | ~ [ ] { } ' /";
        String[] split;
        for (int length = (split = removed_char.split(" ")).length, j = 0; j < length; ++j) {
            final String i = split[j];
            lsent = lsent.replace(i, " ");
        }
        lsent = lsent.replace("\t", " ");
        final String[] tokens = lsent.split(" ");
        final Vector<String> newtoken = new Vector<String>();
        String[] array;
        for (int length2 = (array = tokens).length, k = 0; k < length2; ++k) {
            String token = array[k];
            if (token.matches("^[\\d]+[\\.]?[\\d]*$")) {
                token = "$$NUM$$";
            }
            else {
                token = stemmer(token);
            }
            if (!token.isEmpty()) {
                newtoken.add(token.toLowerCase());
            }
        }
        return newtoken.toArray(new String[1]);
    }
    
    private static String stemmer(final String word) {
        final Stemmer stemmer = new Stemmer();
        for (int i = 0; i < word.length(); ++i) {
            stemmer.add(word.charAt(i));
        }
        stemmer.stem();
        return stemmer.toString().toLowerCase();
    }
    
    public static void main(final String[] argv) {
        final int arg_len = argv.length;
        final String message = "Incorrect input options, use like: \njava -cp ./bin MetaMapWrapper.SenseDisambiguationText text_input_dir card_output_dir\n";
        if (arg_len != 2) {
            System.out.print(message);
            System.exit(-1);
        }
        final String text_dir = argv[0];
        final String card_dir = argv[1];
        final SenseDisambiguationText disambiguation = new SenseDisambiguationText();
        try {
            final HashMap<String, Integer> word_map = new HashMap<String, Integer>();
            BufferedReader infile = new BufferedReader(new FileReader("data/word.txt"));
            String line = "";
            while ((line = infile.readLine()) != null) {
                final String word = line.trim();
                word_map.put(word, 0);
            }
            infile.close();
            final HashMap<String, Integer> abbr_map = new HashMap<String, Integer>();
            infile = new BufferedReader(new FileReader("data/abbr.txt"));
            line = "";
            while ((line = infile.readLine()) != null) {
                final String abbr = line.trim();
                abbr_map.put(abbr, 0);
            }
            infile.close();
            disambiguation.sb = new SentenceBoundary(word_map, abbr_map);
        }
        catch (FileNotFoundException e) {
            e.printStackTrace();
            return;
        }
        catch (IOException e2) {
            e2.printStackTrace();
            return;
        }
        disambiguation.load_profile("profile/");
        disambiguation.load_sense_cui("VABBR_DS_beta.txt.add_semantic_type");
        disambiguation.parse_input(text_dir, card_dir);
    }
}
