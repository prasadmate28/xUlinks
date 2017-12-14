package com.example.aksha.attackerApplication;

import android.content.Intent;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class Main2Activity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main2);


//        final Button urlButton = (Button) findViewById(R.id.btnAppLink);
//        urlButton.setOnClickListener(new View.OnClickListener() {
//            public void onClick(View v) {
//
//
//                Intent intent = new Intent();
//                intent.setAction("android.intent.action.VIEW");
//                //  intent.setAction(Intent.ACTION_VIEW);
//
//                intent.addCategory(Intent.CATEGORY_DEFAULT);
//                intent.addCategory(Intent.CATEGORY_BROWSABLE);
//                Uri data = Uri.parse("http://taitwaleimaging.000webhostapp.com/activityThree/");
//
//                intent.setData(data);
//
//                //  intent.setData(Uri.parse("http://taitwaleimaging.000webhostapp.com/activityThree/"));
//                startActivity(intent);
//            }
//        });
//

        final Button button2 = (Button) findViewById(R.id.button2);
        button2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(Main2Activity.this, activity3.class);
                startActivity(i);
            }
        });
        // ATTENTION: This was auto-generated to handle app links.
        Intent appLinkIntent = getIntent();
        String appLinkAction = appLinkIntent.getAction();
        Uri appLinkData = appLinkIntent.getData();
    }
}
