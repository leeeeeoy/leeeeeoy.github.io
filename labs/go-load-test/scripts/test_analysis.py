import unittest
from analyze import summarize, quantile


class AnalysisTest(unittest.TestCase):
    def test_sample_variation_and_nearest_rank(self):
        result=summarize([10,20,30])
        self.assertEqual(result["mean"],20)
        self.assertEqual(result["sample_sd"],10)
        self.assertEqual(result["cv_percent"],50)
        self.assertEqual(quantile([1,1,2],.5),1.02/1000)
        self.assertEqual(quantile([1,1,2],.99),1.02**2/1000)


if __name__ == "__main__": unittest.main()
