import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.swing.text.Document;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class FindSchemeURL {

	public static void main(String[] args) throws SAXException, IOException {

		// https://docs.oracle.com/javase/tutorial/jaxp/dom/readingXML.html

		DocumentBuilderFactory docBuilderFact = DocumentBuilderFactory.newInstance();

		try {
			DocumentBuilder docBuilder = docBuilderFact.newDocumentBuilder();
			org.w3c.dom.Document doc = docBuilder.parse(new File(
					"C:\\Users\\aksha\\AndroidStudioProjects\\AMDeepLinkDemo\\app\\src\\main\\AndroidManifest.xml"));

			String s = doc.getDocumentElement().getNodeName();
			NodeList activityList = doc.getElementsByTagName("activity");

			for (int i = 0; i < activityList.getLength(); i++) {

				String activityName = ((Element) activityList.item(i)).getAttribute("android:name");
				NodeList activityChildList = activityList.item(i).getChildNodes();

				List<URLDeepLinks> schemeUrls = getSchemeUrls(activityChildList);

				for (URLDeepLinks s1 : schemeUrls) {
					System.out.println();
					System.out.println("*************************************************");
					System.out.println("URLs used for activity :" + activityName);
					String url = s1.scheme + "://" + s1.host + "/" + s1.path;
					System.out.println(url);
					if (CheckHttps(s1.scheme)) {
						System.out.println("Https used!");

					} else {
						System.out.println("Https not used. Vulnerable deep link");
					}

					// System.out.print("The deep link used is not HTTPS; The deep link used for
					// this activity is: ");
					// System.out.println(s1.scheme+":\\"+s1.host+":\\"+s1.path);

				}
			}

		}

		catch (ParserConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		// System.out.println("Hello WOrld");
	}

	private static boolean CheckHttps(String scheme) {

		if (scheme.equals("https"))
			return true;
		else
			return false;
	}

	private static List<URLDeepLinks> getSchemeUrls(NodeList activityChildList)
	{
		List<URLDeepLinks> schemeUrls = new ArrayList<URLDeepLinks>();
		
		for (int i = 0; i < activityChildList.getLength(); i++) {

			if (activityChildList.item(i).getNodeName() == "intent-filter") {
			
				NodeList dataList = activityChildList.item(i).getChildNodes();
				
				for (int k = 0; k < dataList.getLength(); k++) {
					if (dataList.item(k).getNodeName() == "data") {
						Element data = (Element) dataList.item(k);
						
						String scheme = data.getAttribute("android:scheme");
						String host = data.getAttribute("android:host");
						String path = data.getAttribute("android:path");
						
						URLDeepLinks deepLink = new URLDeepLinks();
						deepLink.scheme = scheme;
						deepLink.host = host;
						deepLink.path = path;
						schemeUrls.add(deepLink);
					}
				}
			}
		}
		return schemeUrls;
	}
}
