using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Collections.Generic;
using ats_KNNs;

public partial class KNN : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        //----Training Set--------
        double[] StudentA = new double[] { 9, 32, 65.1 };  //Final Grade A
        double[] StudentB = new double[] { 12, 65, 86.1 };  //Final Grade A-
        double[] StudentC = new double[] { 19, 54, 45.1 };  //Final Grade C
        //------------------------

        List<double[]> TrainingSet = new List<double[]>();
        TrainingSet.Add(StudentA);
        TrainingSet.Add(StudentB);
        TrainingSet.Add(StudentC);

        //------------------------

        //------new Student-------
        List<double> newPlayer = new List<double>();
        newPlayer.Add(Convert.ToDouble(TextBox1.Text));
        newPlayer.Add(Convert.ToDouble(TextBox2.Text));
        newPlayer.Add(Convert.ToDouble(TextBox3.Text));

        double[] newSudent = (double[])newPlayer.ToArray();
        //------------------------

        //compare to all students
        double distance = 0.0;

        for (int i = 0; i < TrainingSet.Count; i++)
        {
            Response.Write("<hr/>");
            //Test the Euclidean Distance calculation between two data points
            distance = KNNs.EuclideanDistance(newSudent, TrainingSet[i]);
            Response.Write("<br/>Euclidean Distance New Student : " + distance);

            distance = KNNs.ChebyshevDistance(newSudent, TrainingSet[i]);
            Response.Write("<br/>Chebyshev Distance New Student : " + distance);

            distance = KNNs.ManhattanDistance(newSudent, TrainingSet[i]);
            Response.Write("<br/>Manhattan Distance New Student : " + distance);
        }

        
    }
}
